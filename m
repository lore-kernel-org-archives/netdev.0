From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: kernel BUG at net/core/skbuff.c:2839 RIP  [<ffffffff819109a2>] skb_segment+0x6b2/0x6d0
Date: Thu, 21 Nov 2013 16:46:18 +0100
Message-ID: <4310398001.20131121164618@eikelenboom.it>
References: <1287049824.20131117201744@eikelenboom.it> <1392359825.20131121130027@eikelenboom.it> <1385043004.10637.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:50538 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab3KUPq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 10:46:27 -0500
In-Reply-To: <1385043004.10637.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, November 21, 2013, 3:10:04 PM, you wrote:

> On Thu, 2013-11-21 at 13:00 +0100, Sander Eikelenboom wrote:
>> Hello Sander,
>> 
>> Sunday, November 17, 2013, 8:17:44 PM, you wrote:
>> 
>> > Hi Eric,
>> 
>> > With the linux-net changes from this merge window i get the kernel panic below (not with 3.12.0).
>> 
>> > It's on a machine running Xen, 2x rtl8169 nic, and using a bridge for guest networking.
>> > This panic in the host kernel only seems to occur when generating a lot of network traffic to and from a guest.
>> 
>> > I tried reverting "tcp: gso: fix truesize tracking" 0d08c42cf9a71530fef5ebcfe368f38f2dd0476f, but that didn't help.

>> Hi Eric and Francois,
>> 
>> I have tested some more:
>> 
>> First tried with switching off GSO and GRO on the bridge, this didn't help.
>> Then i only switched off GRO on eth0 (r8169) and left the bridge alone. That helped to prevent the oops.
>> 
>> Below the output of ethtool -k for the bridge and eth0 after boot (so the default situation) with which the oops occurs.
>> And the part of dmesg where the r8169 get initialized on boot (there are 2, eth0 and eth1).

> As mentioned earlier, this problem is known and a patch is under review.

> http://marc.info/?l=linux-netdev&m=138419594024851&w=2

> Thanks

Ok seems to work for me!

Thx,

Sander
