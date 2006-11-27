From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: VM deadlock avoidance
Date: Mon, 27 Nov 2006 15:06:25 +0100
Message-ID: <1164636385.6588.28.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep19-int.chello.nl ([213.46.243.16]:21617 "EHLO
	amsfep17-int.chello.nl") by vger.kernel.org with ESMTP
	id S1758226AbWK0OMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 09:12:52 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I have a new version of these patches; I'm still using SOCK_VMIO socket
tagging and skb->emergency marks, since I have not come up with another
approach that might work and my RFC to netdev has so far been ignored.

Other than this though, it changed quite a bit;
 - I now use the regular allocation paths and cover all allocations
needed to process a skb (although the RX pool sizing might need more
variables)
 - The emergency RX pool size is based on ip[46]frag_high_thresh and
ip[46]_rt_max_size so that fragment assembly and dst route cache
allocations cannot exhaust the memory. (more paths need analysis xfrm,
conntrack?)
 - skb->emergency packets skip taps
 - skb->emergency packets warn about and ignores NF_QUEUE targets

http://programming.kicks-ass.net/kernel-patches/vm_deadlock/v9/

The patches definitely need more work but would you agree with the
general direction I'm working in or would you suggest yet another
direction?

Kind regards,

Peter

