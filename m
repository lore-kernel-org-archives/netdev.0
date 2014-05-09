From: Rick Jones <rick.jones2@hp.com>
Subject: A SACK block to the left of the ACK? (with ptr to raw trace)
Date: Fri, 09 May 2014 10:34:24 -0700
Message-ID: <536D11A0.6050400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:47503 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779AbaEIReu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 13:34:50 -0400
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com [15.201.208.53])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id B5AE9820
	for <netdev@vger.kernel.org>; Fri,  9 May 2014 17:15:36 +0000 (UTC)
Received: from g9t2301.houston.hp.com (g9t2301.houston.hp.com [16.216.185.78])
	by g4t3425.houston.hp.com (Postfix) with ESMTP id 3366E284
	for <netdev@vger.kernel.org>; Fri,  9 May 2014 17:34:25 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g9t2301.houston.hp.com (Postfix) with ESMTP id 066A167
	for <netdev@vger.kernel.org>; Fri,  9 May 2014 17:34:24 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

As part of looking at a customer issue, I've been running some netperf 
TCP_RR between a pair of instances running 3.2.0 with whatever stuff 
Canonical have backported into their -60 version.  While looking at 
packet traces I've seen the following odd SACK:

08:14:40.329583 IP 15.126.222.122.48130 > 10.0.0.3.12345: Flags [.], ack 
63734, win 457, options [nop,nop,TS val 14282026 ecr 
14255813,nop,nop,sack 1 {63716:63717}], length 0

I don't think that this "to the left of the ACK" SACK block actually 
caused anything heinous to happen but it does look odd and so I thought 
I might mention it to see if anyone else has seen it or if perhaps it is 
a known issue fixed in a later kernel.  The full tcpdump from one side 
is up at:

ftp://ftp.netperf.org/rr_16.pcap.gz

The netperf running was:

ubuntu@zpet-netperf-east-1-vm01:~$ netperf -l 60 -H 
zPet_NetPerf-East-2-vm01 -t TCP_RR -- -b 16 -D -P ,12345

So TCP_NODELAY was set (-D), and there were upwards of 17 segments in 
flight at any one time (-b 16 - 16 added to the default of one).

The trace was taken at zPet_NetPerf-East-2-vm01.  As you might have 
guessed there is NAT involved - in both directions actually.  The 
node(s) on which this NAT is happening are running a 3.5.0-44 kernel.

Here is one being sent from the side where the trace was being taken:

08:15:01.137718 IP 10.0.0.3.12345 > 15.126.222.122.48130: Flags [.], ack 
218871, win 453, options [nop,nop,TS val 14261016 ecr 
14287228,nop,nop,sack 1 {218854:218855}], length 0

Which I suppose rules-out some odd NAT bug as the source of the "to the 
left of the ACK" SACKs since that was captured pre-NAT.

happy benchmarking,

rick jones
