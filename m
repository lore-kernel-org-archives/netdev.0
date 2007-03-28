From: Rick Jones <rick.jones2@hp.com>
Subject: Re: L2 network namespace benchmarking
Date: Wed, 28 Mar 2007 11:08:28 -0700
Message-ID: <460AAF1C.7000102@hp.com>
References: <460997C2.4030902@fr.ibm.com>	<m1ircmunre.fsf@ebiederm.dsl.xmission.com> <460A1F82.9090108@free.fr> <m1r6r9r3eo.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Dmitry Mishin <dim@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:53956 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965622AbXC1SIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 14:08:34 -0400
In-Reply-To: <m1r6r9r3eo.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If I read the results right it took a 32bit machine from AMD with
> a gigabit interface before you could measure a throughput difference.
> That isn't shabby for a non-optimized code path.

Just some paranoid ramblings - one needs to look beyond just whether or 
not the performance of a bulk transfer test (eg TCP_STREAM) remains able 
to hit link-rate.  One has to also consider the change in service demand 
(the normalization of CPU util and throughput).  Also, with 
functionality like TSO in place, the ability to pass very large things 
down the stack can help cover for a multitude of path-length sins.  And 
with either multiple 1G or 10G NICs becoming more and more prevalent, we 
have another one of those "NIC speed vs CPU speed" switch-overs, so 
maintaining single-NIC 1 gigabit throughput, while necessary, isn't 
(IMO) sufficient.

Soooo, it becomes very important to go beyond just TCP_STREAM tests when 
evaluating these sorts of things.  Another test to run would be the 
TCP_RR test.  TCP_RR with single-byte request/response sizes will 
"bypass" the TSO stuff, and the transaction rate will be more directly 
affected by the change in path length than a TCP_STREAM test.  It will 
also show-up quite clearly in the service demand.  Now, with NICs doing 
interrupt coalescing, if the NIC is strapped "poorly" (IMO) then you may 
not see a change in transaction rate - it may be getting limited 
artifically by the NIC's interrupt coalescing.  So, one has to fall-back 
on service demand, or better yet, disable the interrupt coalescing.

Otherwise, measuring peak aggregate request/response becomes necessary.


rick jones
don't be blinded by bit-rate
