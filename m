From: Rick Jones <rick.jones2@hp.com>
Subject: Re: "meaningful" spinlock contention when bound to non-intr CPU?
Date: Fri, 02 Feb 2007 12:41:03 -0800
Message-ID: <45C3A1DF.4050601@hp.com>
References: <45C242C9.1010601@hp.com> <200702022006.31934.ak@suse.de>	<45C396E6.3080705@hp.com> <200702022120.52055.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:36684 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946054AbXBBUlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 15:41:04 -0500
In-Reply-To: <200702022120.52055.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Yes the wakeup happens deep inside the critical section and if the process
> is running on another CPU it could race to the lock.
> 
> Hmm, i suppose the wakeup could be moved out, but it would need some 
> restructuring of the code. Also to be safe the code would still need
> to at least hold a reference count of the sock during the wakeup, and
> when that is released then you have another cache line to bounce,
> which might not be any better than the lock. So it might not be
> actually worth it.
> 
> I suppose the socket release could be at least partially protected with
> RCU against this case so that could be done without a reference count, but 
> it might be tricky to get this right.
> 
> Again still not sure it's worth handling this.

Based on my experiments thusfar I'd have to agree/accept (I wasn't 
certain to begin with - hence the post in the first place :)  but I do 
need/want to see what happens with a single-stream through a 10G NIC - 
on the receive side at least with a 1500 byte MTU.

I was using the burst-mode aggregate RR over the 1G NICs to get the CPU 
util up without need for considerable bandwidth, since the system 
handled 8 TCP_STREAM tests across the 8 NICs without working-up a sweat. 
  I suppose I could instead chop the MTU on the 1G NICs and use that to 
increase the CPU util on the receive side.

rick
