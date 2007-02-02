From: Andi Kleen <ak@suse.de>
Subject: Re: "meaningful" spinlock contention when bound to non-intr CPU?
Date: Fri, 2 Feb 2007 21:20:51 +0100
Message-ID: <200702022120.52055.ak@suse.de>
References: <45C242C9.1010601@hp.com> <200702022006.31934.ak@suse.de> <45C396E6.3080705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:38738 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946042AbXBBUVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 15:21:05 -0500
In-Reply-To: <45C396E6.3080705@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Perhaps a poor choice of words on my part - something along the lines of:
> 
> hold_lock();
> wake_up_someone();
> release_lock();
> 
> where the someone being awoken can try to grab the lock before the path 
> doing the waking manages to release it.

Yes the wakeup happens deep inside the critical section and if the process
is running on another CPU it could race to the lock.

Hmm, i suppose the wakeup could be moved out, but it would need some restructuring
of the code. Also to be safe the code would still need to at least hold a 
reference count of the sock during the wakeup, and when that is released
then you have another cache line to bounce, which might not be any better
than the lock. So it might not be actually worth it.

I suppose the socket release could be at least partially protected with
RCU against this case so that could be done without a reference count, but 
it might be tricky to get this right.

Again still not sure it's worth handling this.

-Andi
