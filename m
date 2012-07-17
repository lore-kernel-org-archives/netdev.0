From: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Subject: RE: timer expiry check at icmp.c in ipv6
Date: Tue, 17 Jul 2012 05:11:06 +0000
Message-ID: <4A71D24947E78D43BC584A7CD4391A41017DBDB4@SIXPRD0410MB359.apcprd04.prod.outlook.com>
References: <4A71D24947E78D43BC584A7CD4391A41017DBBAF@SIXPRD0410MB359.apcprd04.prod.outlook.com>,<1342449217.2830.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:25026
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752665Ab2GQFLV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 01:11:21 -0400
In-Reply-To: <1342449217.2830.3.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Eric,
    Can you please explain it into bit further. Actually what I want to know is how the preferred lifetime value of a router advertisement is processed?, Where it is stored? and while sending the ICMP_REPLY how that preferred lifetime value considered before actually sending the packet? I cannot able to find the relation between icmpv6_echo_reply and fib6_run_gc(). I am very new to kernel source. Kindly help me.

thank you.
________________________________________
From: netdev-owner@vger.kernel.org [netdev-owner@vger.kernel.org] on behalf of Eric Dumazet [eric.dumazet@gmail.com]
Sent: Monday, July 16, 2012 8:03 PM
To: BALAKUMARAN KANNAN
Cc: netdev@vger.kernel.org
Subject: Re: timer expiry check at icmp.c in ipv6

On Mon, 2012-07-16 at 13:44 +0000, BALAKUMARAN KANNAN wrote:
> Dear all,
>
> In kernel-3.0.26 code net/ipv6/icmp.c, while sending ICMP reply where
> it checks for the timer expiry. It should check the value given by a
> router advertisement. I think the expiry value is stored in
> rt->rt6_expires in ndisc.c (line no: 1284). Then while sending an ICMP
> reply, it should check with the expiry timer right? Where that check
> is happening? Please somebody explain me.
>
> Thank you.

Its probably done in net/ipv6/ip6_fib.c

fib6_gc_timer_cb() -> fib6_run_gc()

Every 30 seconds.

(you can change /proc/sys/net/ipv6/route/gc_interval )



