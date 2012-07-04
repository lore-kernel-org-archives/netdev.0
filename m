From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: "ADDRCONF(NETDEV_UP): eth0: link is not ready" with IPv6
Date: Wed, 4 Jul 2012 01:30:35 +0100
Message-ID: <1341361835.2839.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FED14C2.9020200@xdin.com>
	 <1340983473.3066.6.camel@bwh-desktop.uk.solarflarecom.com>
	 <4FF313F6.7010600@xdin.com> <4FF31A99.9010806@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arvid Brodin <Arvid.Brodin@xdin.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@vyatta.com>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23452 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933144Ab2GDAak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 20:30:40 -0400
In-Reply-To: <4FF31A99.9010806@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-03 at 18:15 +0200, Nicolas Ferre wrote:
> On 07/03/2012 05:47 PM, Arvid Brodin :
> > (Added MACB "patch" contact Nicolas Ferre to CC list.)
> 
> Hi,
> 
> (adding linux-arm-kernel)
> 
> > On 2012-06-29 17:24, Ben Hutchings wrote:
> >> On Fri, 2012-06-29 at 02:36 +0000, Arvid Brodin wrote:
> >>> Hi,
> >>>
> >>> After 'ip link set eth0 up' on an avr32 board (network driver macb), the device ends up in
> >>> operational mode "UNKNOWN":
> >>>
> >>> # ip link
> >>> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
> >>>     link/ether 00:24:74:00:17:9d brd ff:ff:ff:ff:ff:ff
> >>>
> >>> Unplugging and plugging in the network cable gets the device to mode "UP".
> >>>
> >>> This is a problem for me because I'm trying to use this device as a "slave" device (for a
> >>> virtual HSR device*) and I need to be able to decide if the slave device is operational or
> >>> not.
> >>>
> >>> Following Stephen's advice here:
> >>> http://kerneltrap.org/mailarchive/linux-netdev/2008/9/24/3398834 I checked the macb.c code
> >>> and noticed they do not call netif_carrier_off() neither before register_netdev() nor in
> >>> dev_open().
> >
> >> It should be called after register_netdev() and before the driver's
> >> ndo_open implementation returns.
> 
> After having read several drivers, it seems that some are calling
> netif_carrier_off() *before* register_netdev() and some *after*... What
> is the proper way?
[...]

The latter is correct; the former is a bug that is tolerated for now:

http://article.gmane.org/gmane.linux.network/111355/

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
