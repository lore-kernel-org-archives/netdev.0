From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 net-next 0/5] net: implement SMC-R solution
Date: Fri, 31 Jul 2015 21:04:52 +0200
Message-ID: <1438369492.12528.6.camel@BR9GV9YG.de.ibm.com>
References: <20150715.212837.233151628267116088.davem@davemloft.net>
	 <1437555592-16506-1-git-send-email-ubraun@linux.vnet.ibm.com>
	 <20150726.161530.2192841818929026804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:35850 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbbGaTEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 15:04:55 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 31 Jul 2015 20:04:54 +0100
In-Reply-To: <20150726.161530.2192841818929026804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-07-26 at 16:15 -0700, David Miller wrote:

> I'm really sorry but this is the same rabbit hole and set of claims
> that have been bullhorned my way for RDMA over the years and I still
> don't buy it.
> 
> None of the RDMA'ish proponents ever talk about what you _don't_ get
> when this stuff triggers.
> 
> No netfilter.
> 
> No packet scheduler.
> 
> No classifier actions.
> 
> No BPF.
> 
> No bridging.
> 
> Basically, every single interesting feature of the Linux networking
> goes away once this RDMA thing happens.
Correct, Dave: All the RDMA protocols do not benefit from packet-based
features of Linux networking. Which is why SMC-R starts with TCP to
maintain some of it. This allows for adhering to the TCP management
model, e.g. for addressing and capability to intercept connection
establishment. We did SMC-R for a good reason -- bringing value to the
mainframe datacenter environment, and potentially other setups, too; and
that includes performance benefits.
> 
> Furthermore the benchmarks are carefully choosen to exemplify the
> perfect environment for this feature to excell at.
Our benchmarks shown are by no means "some carefully chosen" selection.
Would you like to see some other benchmarks?
> 
> Sorry, I don't want any of this in our core networking stack.  You'll
> have to support this completely outside of the TCP implementation and
> core networking code, and therefore have it %100 in your own separate
> module with your own can of worms like the Infiniband et al. people
> do.
Since you are asking for a solution "100% in our own separate module
with our own can of worms", we have to give up the transparent detection
whether a communication peer can do SMC-R or not (this has been the
purpose of the rejected TCP hooks). Instead, we want just the new
self-contained SMC-R socket family added to the kernel. We will adapt
the code accordingly to get rid of TCP experimental options. Is it ok
for you, if we send the whole new code for /net/smc/ in one single patch
since all of it is required for doing the job, or prefer smaller chunks
(which, if half way applied, won't get real functionality)?

Kind regards, Ursula
