From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: L2 network namespace benchmarking
Date: Wed, 28 Mar 2007 21:47:54 +0200
Message-ID: <460AC66A.4060606@fr.ibm.com>
References: <460997C2.4030902@fr.ibm.com>	<m1ircmunre.fsf@ebiederm.dsl.xmission.com> <460A1F82.9090108@free.fr> <m1r6r9r3eo.fsf@ebiederm.dsl.xmission.com> <460AAF1C.7000102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Dmitry Mishin <dim@openvz.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:9581 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965710AbXC1TqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 15:46:10 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l2SJk8S1068330
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 19:46:08 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2SJk88u2781358
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 20:46:08 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2SJk7vv011853
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 20:46:08 +0100
In-Reply-To: <460AAF1C.7000102@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
>> If I read the results right it took a 32bit machine from AMD with
>> a gigabit interface before you could measure a throughput difference.
>> That isn't shabby for a non-optimized code path.
>
> Just some paranoid ramblings - one needs to look beyond just whether 
> or not the performance of a bulk transfer test (eg TCP_STREAM) remains 
> able to hit link-rate.  One has to also consider the change in service 
> demand (the normalization of CPU util and throughput).  Also, with 
> functionality like TSO in place, the ability to pass very large things 
> down the stack can help cover for a multitude of path-length sins.  
> And with either multiple 1G or 10G NICs becoming more and more 
> prevalent, we have another one of those "NIC speed vs CPU speed" 
> switch-overs, so maintaining single-NIC 1 gigabit throughput, while 
> necessary, isn't (IMO) sufficient.
>
> Soooo, it becomes very important to go beyond just TCP_STREAM tests 
> when evaluating these sorts of things.  Another test to run would be 
> the TCP_RR test.  TCP_RR with single-byte request/response sizes will 
> "bypass" the TSO stuff, and the transaction rate will be more directly 
> affected by the change in path length than a TCP_STREAM test.  It will 
> also show-up quite clearly in the service demand.  Now, with NICs 
> doing interrupt coalescing, if the NIC is strapped "poorly" (IMO) then 
> you may not see a change in transaction rate - it may be getting 
> limited artifically by the NIC's interrupt coalescing.  So, one has to 
> fall-back on service demand, or better yet, disable the interrupt 
> coalescing.
>
> Otherwise, measuring peak aggregate request/response becomes necessary.
>
>
> rick jones
> don't be blinded by bit-rate
Thanks Rick,

Do you have any pointer to help on benchmarking the network, perhaps a 
checklist or some scripts for netperf ?

Regards.
    -- Daniel
