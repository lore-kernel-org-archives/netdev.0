From: Rick Jones <rick.jones2@hp.com>
Subject: a wrinkle to consider when benchmarking with LRO
Date: Wed, 09 May 2007 15:22:46 -0700
Message-ID: <464249B6.6050506@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:38173 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754782AbXEIWWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 18:22:48 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel10.hp.com (Postfix) with ESMTP id 5CC333487A
	for <netdev@vger.kernel.org>; Wed,  9 May 2007 15:22:47 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id PAA26687
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 15:22:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the risk of pointing-out the known/obvious...

I have been evaluating a system and its ability to source data across a 10G 
link.  My number of 10G sink's is a triffle minimal.  To maximize the sinks' 
ability to sink data I enabled large receive offload.  The kernel on the sinks 
was 2.6.21.1.  The kernel on the source was "another OS."

While TSO doesn't especially change what is seen on the wire, LRO can.  When the 
NIC/driver combines the segments, the receiving TCP sends fewer ACKs.  In short, 
LRO is an implicit/backdoor ACK avoidance heuristic.

So, the sending TCP will receive fewer ACKs and will have a correspondingly 
lower CPU overhead and so will be able to source data faster than if it were 
sending to a system without LRO enabled.

I'm not trying to say this is a bad thing - in fact, I have gone on record a 
number of times supporting good ACK avoidance heuristics - I just wanted to make 
sure this behaviour I was seeing was on the record somewhere as it may not be 
obvious to everyone.

happy benchmarking,

rick jones
