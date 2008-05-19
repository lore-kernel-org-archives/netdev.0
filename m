From: Steve.Glendinning@smsc.com
Subject: RE: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC addresssetting
 after reset
Date: Mon, 19 May 2008 14:03:31 +0100
Message-ID: <OF35F08D73.56884FA4-ON8025744E.0047900A-8025744E.0047BBC0@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3552 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751140AbYESNDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 09:03:55 -0400
Received: from mta.smsc.com (mta [170.129.83.113])
	by internal.smsc.com (8.12.10/8.8.5) with ESMTP id m4JD3ZC7007376
	for <netdev@vger.kernel.org>; Mon, 19 May 2008 09:03:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(re-sending to netdev in plain text)

Hi Michael,

I've been maintaining the smsc911x driver out-of-tree, I'll send my latest 
full patch following this email.  Bill Gatliff already fixed the same MAC 
address issue, and I've added support for the new LAN9210 and LAN9211 
devices.

(adding netdev to cc) I'd still like to see this driver replace smc911x in 
mainline, how does everyone else feel?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com





"Hennerich, Michael" <Michael.Hennerich@analog.com> 
16/05/2008 11:58

To
"Enrik Berkhan" <Enrik.Berkhan@ge.com>, Steve Glendinning/SMSC@SMSC
cc
<hennerich@blackfin.uclinux.org>, Ian Saturley/SMSC@SMSC, 
<uclinux-dist-devel@blackfin.uclinux.org>, <bahadir.balban@arm.com>, 
<bgat@billgatliff.com>
Subject
RE: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC addresssetting 
after reset






Hi Steve,

I received a patch to address the MAC address soft reset issue,
discussed before.

Is there a newer driver with this and maybe other fixes?

Some time ago I thought this driver is going to be mainlined.
Are you still panning to get it merged, - replace smc911x.c.

-Michael

>-----Original Message-----
>From: uclinux-dist-devel-bounces@blackfin.uclinux.org
[mailto:uclinux-dist-
>devel-bounces@blackfin.uclinux.org] On Behalf Of Enrik Berkhan
>Sent: Donnerstag, 15. Mai 2008 19:08
>To: uclinux-dist-devel@blackfin.uclinux.org
>Subject: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC
>addresssetting after reset
>
>The SMSC911X driver soft-resets the chip on open(). This makes the
>chip forget and re-load its MAC address from its EEPROM, if avail-
>able.
>
>If the MAC address has been set externally (e. g. by the bootloader
>or via command line), this setting is lost. This patch fixes the
>problem by always setting the saved MAC address after soft reset.
>
>Signed-Off-By: Enrik Berkhan <Enrik.Berkhan@ge.com>
>---
> drivers/net/smsc911x.c |    4 ++++
> 1 file changed, 4 insertions(+)
>
>Index: drivers/net/smsc911x.c
>===================================================================
>--- drivers/net/smsc911x.c.orig                 2008-05-15 
18:49:30.000000000
+0200
>+++ drivers/net/smsc911x.c              2008-05-15 18:51:28.000000000 
+0200
>@@ -1182,6 +1182,10 @@ static int smsc911x_open(struct net_devi
>                                udelay(10);
>                }
>
>+               /* Set MAC again in case it has been set from non-EEPROM 
source
>+                * (config or even bootloader) */
>+               smsc911x_set_mac_address(pdata, dev->dev_addr);
>+
>                if (unlikely(timeout == 0)) {
>                                SMSC_WARNING("Timed out waiting for 
EEPROM "
>                                                     "busy bit to 
clear");
>_______________________________________________
>Uclinux-dist-devel mailing list
>Uclinux-dist-devel@blackfin.uclinux.org
>http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel


