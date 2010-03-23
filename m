From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase	enqueue/dequeue
 fairness
Date: Tue, 23 Mar 2010 13:40:00 -0700
Message-ID: <4BA92720.5090403@hp.com>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:10146 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079Ab0CWUkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 16:40:03 -0400
In-Reply-To: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck wrote:
> The qdisc layer shows a significant issue when you start transmitting from
> multiple CPUs.  The issue is that the transmit rate drops significantly, and I
> believe it is due to the fact that the spinlock is shared between the 1
> dequeue, and n-1 enqueue cpu threads.  In order to improve this situation I am
> adding one additional lock which will need to be obtained during the enqueue
> portion of the path.  This essentially allows sch_direct_xmit to jump to
> near the head of the line when attempting to obtain the lock after
> completing a transmit.
> 
> Running the script below I saw an increase from 200K packets per second to
> 1.07M packets per second as a result of this patch.
> 
> for j in `seq 0 15`; do
> 	for i in `seq 0 7`; do
> 		netperf -H <ip> -t UDP_STREAM -l 600 -N -T $i -- -m 6 &
> 	done
> done


Wow - someone is using the no control connection mode in netperf :)  Or were you 
actually trying to get the test-specific -N option to control whether or not 
netperf "connects" the UDP socket?

rick jones
