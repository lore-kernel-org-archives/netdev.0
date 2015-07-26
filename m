From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 0/5] net: implement SMC-R solution
Date: Sun, 26 Jul 2015 16:15:30 -0700 (PDT)
Message-ID: <20150726.161530.2192841818929026804.davem@davemloft.net>
References: <20150715.212837.233151628267116088.davem@davemloft.net>
	<1437555592-16506-1-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655AbbGZXPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 19:15:32 -0400
In-Reply-To: <1437555592-16506-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Wed, 22 Jul 2015 10:59:47 +0200

> 1. Provides optimized performance compared to standard TCP/IP over Ethernet
>    within the data center for both request/response (latency) and streaming
>    workloads (CPU savings) [3]. 
>    Initial benchmarks on Linux on x86 processors have shown latency
>    reduction of up to 52% with a throughput gain of 111% using SMC-R vs TCP
>    for request/response message patterns (10 concurrent TCP connections
>    with 16KB    messages) and CPU savings of up to 69% for streaming data
>    patterns (single TCP connection with 20MB of data in one direction).
>    [1] is currently updated to contain more detailed information on Linux
>    and performance.

I'm really sorry but this is the same rabbit hole and set of claims
that have been bullhorned my way for RDMA over the years and I still
don't buy it.

None of the RDMA'ish proponents ever talk about what you _don't_ get
when this stuff triggers.

No netfilter.

No packet scheduler.

No classifier actions.

No BPF.

No bridging.

Basically, every single interesting feature of the Linux networking
goes away once this RDMA thing happens.

Furthermore the benchmarks are carefully choosen to exemplify the
perfect environment for this feature to excell at.

Sorry, I don't want any of this in our core networking stack.  You'll
have to support this completely outside of the TCP implementation and
core networking code, and therefore have it %100 in your own separate
module with your own can of worms like the Infiniband et al. people
do.

Having this standardized or "in widespread successful use" has no
bearing upon the things I do not like about this patch set, so do not
use those kinds of arguments to try and change my mind.  It won't
work.

I'm not applying this patch series.
