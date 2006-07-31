From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: IBM (Lenovo) T60: e1000 driver high latency
Date: Mon, 31 Jul 2006 08:05:27 -0700
Message-ID: <44CE1C37.2090001@intel.com>
References: <20060731093433.GF2576@cip.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39200 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1750879AbWGaPGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 11:06:43 -0400
To: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>
In-Reply-To: <20060731093433.GF2576@cip.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Glanzmann wrote:
> Hello,
> 
>    [ resend because .config and the used kernel version was missing ]
> 
> Linux Kernel Version: Linus Vanilla Tree; .config attached.
> 
> I recently aquired a Lenovo (IBM) T60 with a e1000 network card. I
> experience high latency with this networkcard: Pings last upto 1 second
> where the ping should be around 25 ms. I googled a bit and found the
> following:
> 
> - Enable NAPI, which didn't worked for me.
> 
>         64 bytes from 192.168.0.223: icmp_seq=30 ttl=64 time=1004 ms
>         64 bytes from 192.168.0.223: icmp_seq=31 ttl=64 time=0.444 ms
>         64 bytes from 192.168.0.223: icmp_seq=32 ttl=64 time=1006 ms
>         64 bytes from 192.168.0.223: icmp_seq=33 ttl=64 time=0.739 ms

Someone reported this problem on the e1000 bug tracker at e1000.sf.net.

He also reported that the behaviour goes away completely if he disables the 
in-kernel irq balancer:

: If I disable in kernel config Irq Balancing pings are
: much better but not the best  :-)
:
: 64 bytes from 192.168.3.74: icmp_seq=29 ttl=64 time=12.7 ms
: 64 bytes from 192.168.3.74: icmp_seq=30 ttl=64 time=10.0 ms
: 64 bytes from 192.168.3.74: icmp_seq=31 ttl=64 time=7.3 ms
: 64 bytes from 192.168.3.74: icmp_seq=32 ttl=64 time=4.5 ms

that's a large difference from >> 1000ms, and I cannot suspect otherwise that 
the kernel irqbalance is wreaking havoc in your system, trying to swap the 
entire context between each core (t60 is a core duo) every second or so.

I've never believed much in the kernel irq balancer, the userspace daemon 
written by Arjan van der Ven just does a much better job, so can you try to 
disable the kernel irqbalancer?

 > CONFIG_IRQBALANCE=y

turn that off ;)


Cheers,

Auke
