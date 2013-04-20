From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Sat, 20 Apr 2013 10:57:15 -0400
Message-ID: <5172ACCB.9050203@mojatatu.com>
References: <20130419120651.4e646976@nehalam.linuxnetplumber.net> <20130419194537.GA1633@kroah.com> <20130419.155859.1092595631804890737.davem@davemloft.net> <51727C76.6010501@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	Eric Leblond <eric@regit.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Luigi Rizzo <rizzo@iet.unipi.it>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:47685 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481Ab3DTO5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 10:57:23 -0400
Received: by mail-ie0-f171.google.com with SMTP id e11so5729428iej.16
        for <netdev@vger.kernel.org>; Sat, 20 Apr 2013 07:57:22 -0700 (PDT)
In-Reply-To: <51727C76.6010501@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-04-20 07:31 AM, Daniel Borkmann wrote:

> Also, I just looked over Netmap's Usenix paper from 2012, where they
> compare netmap against pktgen, and while they state the version of the FreeBSD
> kernel
> where they did the evaluation on, they just don't even mention the Linux'
> kernel version, their Linux kernel setup etc. Not even mentioning a
> comparison
> of PF_PACKET+fanout (similarly as the PF_RING project seems to avoid this
> comparison and only presents perf numbers where they just count packets !).
> Also, I've seen other papers published in 2012 on this topic, where they
> compare performance with a 2.6.2x kernel, hm, quite sad actually.

I hope I can put your doubts to rest. Netmap does provide the 
performance it claims to. I did play with it about 6-9 months back and i 
was able to loopback wirerate 10Gbps (~14.4Mpps) 64B packets on a 
_single core_. i.e i send to from machine A to B which echoes back to 
the sender via a driver hack i had on the intel driver and i count the 
packets. I should note that this was with machines that have circa 2010 
capabilities (and they were cheap too).

It is true without some changes to the kernel (such as using multiqueues 
and batching, pktgen will not be able to achieve that speed). It would 
be interesting to see what you can achieve with PF_PACKET transmit. 
PF_PACKET is already behind if you have to depend on fanout for receive 
(you are using more processing).
Granted that this was a simple app. Unfortunately the trend with 
approaches like netmap is happening. Theres some closed source thing out 
of intel called DPDK which intel is aggressively marketing.
If someone is showing you 10x improvement over what Linux gives you,
then we are doing something wrong and we shouldnt be living in some
parallel universe and claim theres nothing to see here.
1.5-3x is something i can live with because it shows theres some room
for tweaking.

 From a personal perspective - I have always been a supporter of "if 
something is wrong with what linux gives you, lets improve it" (Still 
grinding my teeth at openvswitch).
How about we learn something from this and try to improve what we have?
I did talk to Luigi briefly (CCing him) - his biggest beef was with skbs
and how fat they are. I know Eric D. has been doing some excellent work
putting them on some low-carb diet but there are still people showing up
and arguing for more fields. Here's a thought:
Could we put something in the kernel that allows for high-perfomance 
zero copy to user  space and inject packets + metadata (from/to 
arbitrary parts of the kernel)? I do this all the time from say 
ingress/egress via tuntap (which sucks at this).
Yes, theres a danger of allowing for competing interfaces in userspace
to develop tcp stacks etc but I think for someone who wants to take 
advantage of Linux, thats a non-starter.

cheers,
jamal
