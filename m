From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Tue, 26 Aug 2008 09:51:26 +0000
Message-ID: <20080826095126.GA2609@ff.dom.local>
References: <200808220457.40892.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:59147 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbYHZJvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 05:51:32 -0400
Received: by ey-out-2122.google.com with SMTP id 6so271912eyi.37
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 02:51:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808220457.40892.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22-08-2008 03:57, Denys Fedoryshchenko wrote:
> I have loaded router (~650 Mbps In+Out), based on 2xAMD Opteron 248, Sun Fire 
> X4100. HPET timer available (TSC seems not available on this platform).
> Network interfaces is onboard, connected over PCI-X.
> 
> Right now i am using only one processor, cause using only one interface and 
> interrupts stick to it. Other is almost not used.
> At peak time i notice in mpstat, that this processor is almost "dead", and if 
> i run minor application consuming resources - ping over this router will be 
> terrible. For me it is clear - system overloaded. I did oprofile, and here is 
> result (at low load time, but at peak time it is very similar).
...
> CPU: AMD64 processors, speed 2193.74 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit 
> mask of 0x00 (No unit mask) count 100000
> samples  %        symbol name
> 1031727  37.1736  getnstimeofday
> 230457    8.3035  __napi_schedule
> 122154    4.4013  __do_softirq
> 110036    3.9647  dev_queue_xmit
...
> What is bothering me, why getnstimeofday called so much? Even i remove HTB 
> shaper, it still takes 30-40% of whole vmlinux time. From other 
> applications - only zebra is running.
> Any ideas?

This function is really used in many places, and these profiles are
not enough at least to me, but it seems you could have a lot of
softirqs (and probably hrtimers) scheduling, so maybe you should try
if e.g. disabling hrtimers or changing kernel HZ makes any difference.

Jarek P.
