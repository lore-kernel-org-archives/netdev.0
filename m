From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: "meaningful" spinlock contention when bound to non-intr CPU?
Date: Fri, 2 Feb 2007 08:47:19 -0800
Message-ID: <4807377b0702020847n11da1298ncdb5cf1609c8f0d2@mail.gmail.com>
References: <45C242C9.1010601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Network Development list" <netdev@vger.kernel.org>
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:27214 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945958AbXBBQrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 11:47:21 -0500
Received: by ug-out-1314.google.com with SMTP id 44so808473uga
        for <netdev@vger.kernel.org>; Fri, 02 Feb 2007 08:47:19 -0800 (PST)
In-Reply-To: <45C242C9.1010601@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/1/07, Rick Jones <rick.jones2@hp.com> wrote:
<snip>
> With some help from Lee Schermerhorn and Alan Brunelle I got a lockmeter
> kernel going, and it is suggesting that the greatest spinlock contention
> comes from the routines:
>
> SPINLOCKS         HOLD            WAIT
>    UTIL  CON    MEAN(  MAX )   MEAN(  MAX )(% CPU)     TOTAL NOWAIT SPIN
> RJECT  NAME
>
>    7.4%  2.8%  0.1us( 143us)  3.3us( 147us)( 1.4%)  75262432 97.2%  2.8%
>     0%  lock_sock_nested+0x30
>   29.5%  6.6%  0.5us( 148us)  0.9us( 143us)(0.49%)  37622512 93.4%  6.6%
>     0%  tcp_v4_rcv+0xb30
>    3.0%  5.6%  0.1us( 142us)  0.9us( 143us)(0.14%)  13911325 94.4%  5.6%
>     0%  release_sock+0x120
>    9.6% 0.75%  0.1us( 144us)  0.7us( 139us)(0.08%)  75262432 99.2% 0.75%
>     0%  release_sock+0x30
>
> I suppose it stands to some reason that there would be contention
> associated with the socket since there will be two things going for the
> socket (a netperf/netserver and an interrupt/upthestack) each running on
> separate CPUs.  Some of it looks like it _may_ be inevitable? -
> waking-up the user who will now  be racing to grab the socket before the
> stack releases it? (I may have been mis-interpreting some of the code I
> was checking)
>
> Still, does this look like something worth persuing?  In a past life/OS
> when one was able to eliminate one percentage point of spinlock
> contention, two percentage points of improvement ensued.

Rick, this looks like good stuff, we're seeing more and more issues
like this as systems become more multi-core and have more interrupts
per NIC (think MSI-X)

Let me know if there is something I can do to help.
