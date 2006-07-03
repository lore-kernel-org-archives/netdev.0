From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH 9/15] pcmcia: hostap_cs.c - 0xc00f, 0x0000 conflicts with pcnet_cs
Date: Mon, 3 Jul 2006 10:56:03 +0200
Message-ID: <20060703085603.GA9465@dominikbrodowski.de>
References: <20060630195217.GB9095@dominikbrodowski.de> <20060630195255.GC9095@dominikbrodowski.de> <20060630195358.GD9095@dominikbrodowski.de> <20060630195439.GE9095@dominikbrodowski.de> <20060630195501.GF9095@dominikbrodowski.de> <20060630195600.GG9095@dominikbrodowski.de> <20060630195657.GH9095@dominikbrodowski.de> <20060630195753.GI9095@dominikbrodowski.de> <20060630195920.GJ9095@dominikbrodowski.de> <1151702323.21767.3.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	hostap@shmoo.com, linville@tuxdriver.com, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.239.214.66]:35476 "EHLO linta.de")
	by vger.kernel.org with ESMTP id S1750895AbWGCI4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 04:56:10 -0400
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1151702323.21767.3.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

On Fri, Jun 30, 2006 at 05:18:43PM -0400, Pavel Roskin wrote:
> On Fri, 2006-06-30 at 21:59 +0200, Dominik Brodowski wrote:
> > -	PCMCIA_DEVICE_MANF_CARD(0xc00f, 0x0000),
> > +/*	PCMCIA_DEVICE_MANF_CARD(0xc00f, 0x0000),    conflict with pcnet_cs */
> 
> That's fine if we also add symbolic names.  I could identify two
> hostap_cs compatible cards using this ID :
> 
> card "Allied Telesyn AT-WCL452"
>  version "Allied Telesyn", "AT-WCL452 Wireless PCMCIA Radio", "Ver.
> 1.00"
>  manfid 0xc00f, 0x0000
>  bind "hostap_cs"
> 
> card "corega WL PCCL-11"
>  version "corega", "WL PCCL-11", "ISL37300P", "RevA"
>  manfid 0xc00f, 0x0000
>  bind "hostap_cs"

Like this?

From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Sun, 2 Jul 2006 21:21:51 +0200
Subject: [PATCH] pcmcia: add more IDs to hostap_cs.c

As a replacement for the broad manufactor/card ID match we commented out
because of conflicts with pcnet_cs, add two product ID matches.

Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/wireless/hostap/hostap_cs.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 52e6df5..f39d735 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -886,6 +886,13 @@ static struct pcmcia_device_id hostap_cs
 	PCMCIA_DEVICE_PROD_ID123(
 		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02",
 		0xc7b8df9d, 0x1700d087, 0x4b74baa0),
+	PCMCIA_DEVICE_PROD_ID123(
+		"Allied Telesyn", "AT-WCL452 Wireless PCMCIA Radio",
+		"Ver. 1.00",
+		0x5cd01705, 0x4271660f, 0x9d08ee12),
+	PCMCIA_DEVICE_PROD_ID1234(
+		"corega", "WL PCCL-11", "ISL37300P", "RevA",
+		0xa21501a, 0x59868926, 0xc9049a39, 0x57a66194),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);
-- 
1.4.0

