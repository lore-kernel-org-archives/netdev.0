From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Mon, 09 Mar 2009 17:34:47 -0700
Message-ID: <49B5B5A7.8090502@hp.com>
References: <20090309112521.GB37984@bts.sk>	<1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>	<20090309200505.GA58375@bts.sk> <20090309.170927.130334650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: md@bts.sk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:25200 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759AbZCJAez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 20:34:55 -0400
In-Reply-To: <20090309.170927.130334650.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If I recall correctly, when I have asked about this behaviour in the past, I was 
told that the autotuning receiver would always try to offer the sender 2X what 
the receiver thought the sender's cwnd happened to be.  Is my recollection 
incorrect, or is this then:

[root@dl5855 ~]# netperf -t omni -H sut42 -- -k foo -s 128K
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to sut42.west (10.208.0.45) port 
0 AF_INET
THROUGHPUT=941.30
LSS_SIZE_REQ=131072
LSS_SIZE=262142
LSS_SIZE_END=262142
RSR_SIZE_REQ=-1
RSR_SIZE=87380
RSR_SIZE_END=3900000

not intended behaviour?  LSS == Local Socket Send; RSR == Remote Socket Receive. 
  dl5855 is running RHEL 5.2 (2.6.18-92.el5) sut42 is running a nf-next-2.6 about 
two or three weeks old with some of the 32-core scaling patches applied 
(2.6.29-rc5-nfnextconntrack)

I'm assuming that by setting the SO_SNDBUF on the netperf (sending) side to 
128K/256K that will be the limit on what it will ever put out onto the connection 
at one time, but by the end of the 10 second test over the local GbE LAN the 
receiver's autotuned SO_RCVBUF has grown to 3900000.

rick jones
