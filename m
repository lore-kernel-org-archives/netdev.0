From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: Fwd: Re: [RFC] kvm tools: Implement multiple VQ for virtio-net
Date: Fri, 25 Nov 2011 02:47:44 -0500
Message-ID: <20111125074744.GA5705@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Pekka Enberg <penberg@kernel.org>,
	Asias He <asias.hejun@gmail.com>,
	Sasha Levin <levinsasha928@gmail.com>, kvm@vger.kernel.org,
	mingo@elte.hu, gorcunov@gmail.com,
	Krishna Kumar <krkumar2@in.ibm.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	Benjamin Poirier <benjamin.poirier@gmail.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.openrapids.net ([64.15.138.104]:55609 "EHLO
	blackscsi.openrapids.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752374Ab1KYHyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 02:54:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Benjamin forwarded me your email stating:

> I have been playing with userspace-rcu which has a number of neat
> lockless routines for queuing and hashing. But there aren't kernel versions
> and several of them may require cmpxchg to work.

Just FYI, I made sure a few years ago that cmpxchg is implemented on all
architectures within the Linux kernel (using a interrupt disable
fallback on the cases where it is not supported architecturally, on
UP-only architectures), so we should be good to use the lock-free
structures as-is in the kernel on this front. As for the RCU use by
these structures, userspace RCU has very much the same semantic as in
the kernel, so we can implement and test these structures in userspace
and eventually port them to the kernel as needed.

Lai Jiangshan is actively working at making sure the user-level
implementation of the RCU lock-free hash table (currently in a
development branch of the userspace RCU git tree : urcu/ht-shrink, not
yet in master) is suitable for use in the Linux kernel too.

Best regards,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
