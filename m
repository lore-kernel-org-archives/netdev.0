From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: TC-HTB issue : low throughput
Date: Sun, 08 Nov 2009 00:31:21 +0100
Message-ID: <4AF60349.8000502@gmail.com>
References: <20091107024305.GA32398@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:39774 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbZKGXbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2009 18:31:21 -0500
Received: by bwz27 with SMTP id 27so2334860bwz.21
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2009 15:31:26 -0800 (PST)
In-Reply-To: <20091107024305.GA32398@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean Tourrilhes wrote, On 11/07/2009 03:43 AM:

> 	Hi,
> 
> 	I'm playing with a TC-HTB. I'm noticing that the throughput is
> low. As the LARTC mailing list seems to be dead, I would welcome
> suggestions...
> 	The example below may seem contrived, but I reduced it to
> a simple testcase to make it easier to reproduce.
> 
> System :
> ------
> 	Debian Lenny with 2.6.30.9
> 	Quad Core 2.5 GHz Q9300
> 	Intel 1Gb/s NIC, e1000e drive

...

> Topology :
> --------
> Four PCs with Linux :
> 10.10.10.32 on br0
> 10.10.10.33 connected to eth5.33 (sender)
> 10.10.10.38 connected to eth7.38 (sender)
> 10.10.10.34 connected to eth6.34 (receiver)
> 
> Behaviour :
> ---------
> 	If I set only qdisc 1: and class 1:1, but *NOT* 1:2 and 1:3 :
> 	Each host independantly : ~935 Mb/s
> 	Both host together, for 10.10.10.38 : ~527 Mb/s ;
> 	Both host together, for 10.10.10.33 : ~443 Mb/s
> 
> 	If I add classes 1:2 and 1:3 :
> 	Each host independantly : ~170 Mb/s.
> 	Both host together, for 10.10.10.38 : ~106 Mb/s ;
> 	Both host together, for 10.10.10.33 : ~135 Mb/s
> 
> 	So, not only performance did drop significantely, but
> prioritisation did not happen as expected.

If these eths are vlans (or other virtuals) something like this
often happens if you forget to set dev's txqueuelen before
adding classes (or a subqdisc with some 'limit').

> Weird detail :
> ------------
> 	I've noticed that /sbin/tc calculates a very low burst
> value. This is due to the content of /proc/net/psched. I'm wondering
> if the burst calculation is what causes the issue here.
> 	However, I tried with "burst 50kb" and saw no difference...

There is (probably still) unfixed overflow in tc.

BTW, v2.6.31 should be more exact (but so much...) for above 100mbit
scheduling, especially with this patch to iproute2:
http://marc.info/?l=linux-netdev&m=124453482324409&w=2

Jarek P.
