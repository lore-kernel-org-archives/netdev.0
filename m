From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG at net/core/skbuff.c:2839 RIP  [<ffffffff819109a2>]
 skb_segment+0x6b2/0x6d0
Date: Thu, 21 Nov 2013 06:10:04 -0800
Message-ID: <1385043004.10637.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1287049824.20131117201744@eikelenboom.it>
	 <1392359825.20131121130027@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:53550 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab3KUOKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 09:10:05 -0500
Received: by mail-pb0-f42.google.com with SMTP id uo5so11641478pbc.15
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 06:10:05 -0800 (PST)
In-Reply-To: <1392359825.20131121130027@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 13:00 +0100, Sander Eikelenboom wrote:
> Hello Sander,
> 
> Sunday, November 17, 2013, 8:17:44 PM, you wrote:
> 
> > Hi Eric,
> 
> > With the linux-net changes from this merge window i get the kernel panic below (not with 3.12.0).
> 
> > It's on a machine running Xen, 2x rtl8169 nic, and using a bridge for guest networking.
> > This panic in the host kernel only seems to occur when generating a lot of network traffic to and from a guest.
> 
> > I tried reverting "tcp: gso: fix truesize tracking" 0d08c42cf9a71530fef5ebcfe368f38f2dd0476f, but that didn't help.

> Hi Eric and Francois,
> 
> I have tested some more:
> 
> First tried with switching off GSO and GRO on the bridge, this didn't help.
> Then i only switched off GRO on eth0 (r8169) and left the bridge alone. That helped to prevent the oops.
> 
> Below the output of ethtool -k for the bridge and eth0 after boot (so the default situation) with which the oops occurs.
> And the part of dmesg where the r8169 get initialized on boot (there are 2, eth0 and eth1).

As mentioned earlier, this problem is known and a patch is under review.

http://marc.info/?l=linux-netdev&m=138419594024851&w=2

Thanks
