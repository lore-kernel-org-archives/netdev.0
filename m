From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Mon, 24 Feb 2014 17:38:59 -0800
Message-ID: <1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg>
	 <1393280025.2316.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402250056250.1941@ja.home.ssi.bg>
	 <1393284682.2316.83.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140224155130.4c286cca@samsung-9>
	 <1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:39013 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752212AbaBYBjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 20:39:00 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so7049081pde.41
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 17:39:00 -0800 (PST)
In-Reply-To: <1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-24 at 17:11 -0800, Eric Dumazet wrote:
> On Mon, 2014-02-24 at 15:51 -0800, Stephen Hemminger wrote:
> 
> > 
> > The original reason I kept ms resolution and added the flag was
> > that accessing high resolution time is expensive for systems where
> > TSC is not stable.  Google may live in a world of SMP systems with
> > good X86 CPUs with working TSC, but other architectures and system
> > config's may have non-working TSC.
> 
> Well, it seems we now have alternatives to ktime_get() that were
> probably not yet there at the time you made this choice ?
> 
> We only want a reasonable alternative to jiffies based measures,
> we do not need ultra precise and synchronized clocks.
> 
> I'll redo tests with hpet clocksource, and local_clock()

Interesting : Using current net-next kernel, before my patches I get
on a TCP_RR workload :

It seems nobody is seriously using hpet these days with recent kernels.


    29.98%  [kernel]      [k] read_hpet                     
     2.93%  [kernel]      [k] _raw_spin_lock                
     1.63%  [kernel]      [k] __schedule                    
     1.62%  [bnx2x]       [k] bnx2x_start_xmit              
     1.57%  [kernel]      [k] __netif_receive_skb_core      
     1.45%  [kernel]      [k] tcp_ack                       
     1.30%  [kernel]      [k] idle_cpu                      
     1.29%  [kernel]      [k] __switch_to                   
     1.28%  netperf       [.] send_omni_inner               
     1.05%  libc-2.15.so  [.] __libc_recv                   
     0.98%  [kernel]      [k] ipv4_dst_check                
