From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH FINAL] Merge the Sonics Silicon Backplane subsystem
Date: Tue, 31 Jul 2007 20:26:48 -0700
Message-ID: <20070731202648.e1a8c45f.akpm@linux-foundation.org>
References: <200707291324.58691.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel@vger.kernel.org>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>,
	John Linville <linville@tuxdriver.com>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35736 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754208AbXHAD2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 23:28:08 -0400
In-Reply-To: <200707291324.58691.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 29 Jul 2007 13:24:54 +0200 Michael Buesch <mb@bu3sch.de> wrote:

> The Sonics Silicon Backplane is a mini-bus used on
> various Broadcom chips and embedded devices.

Sigh.

s390:

drivers/ssb/main.c: In function 'ssb_ssb_read16':
drivers/ssb/main.c:489: error: implicit declaration of function 'readw'
drivers/ssb/main.c: In function 'ssb_ssb_read32':
drivers/ssb/main.c:497: error: implicit declaration of function 'readl'
drivers/ssb/main.c: In function 'ssb_ssb_write16':
drivers/ssb/main.c:505: error: implicit declaration of function 'writew'
drivers/ssb/main.c: In function 'ssb_ssb_write32':
drivers/ssb/main.c:513: error: implicit declaration of function 'writel'        

we shouldn't be compiling SSB on s390, because:

config SSB
        tristate "Sonics Silicon Backplane support"
        depends on EXPERIMENTAL && HAS_IOMEM

and

akpm2:/usr/src/25> grep IOMEM .config 
CONFIG_NO_IOMEM=y
akpm2:/usr/src/25> 

but

akpm2:/usr/src/25> grep SSB .config 
CONFIG_DCSSBLK=m
CONFIG_SSB=m
CONFIG_SSB_SILENT=y

well, how did that come about?

It _has_ to be `select'.  It's _always_ `select'.

yup, it's `select':

Selected by: B44 && NETDEVICES && NET_ETHERNET || BCM43XX_MAC80211 && NETDEVICES && !S390 && MAC80211 && WLAN_80211 && EXPERIMENTAL


Look.  Kconfig's `select' Just.  Does.  Not.  Work.  If you find yourself
contemplating using it, please, don sackcloth, take a cold shower and
several analgesics, then have another go, OK?

ho hum.

