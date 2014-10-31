From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Fri, 31 Oct 2014 10:24:05 +0100
Message-ID: <54535535.3040900@redhat.com>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>  <20141028.165737.2009356944765978630.davem@davemloft.net>  <20141029122307.GA29253@breakpoint.cc>  <20141030.155958.156984068627586090.davem@davemloft.net>  <20141030205204.GE10069@breakpoint.cc>  <1414703260.15352.9.camel@edumazet-glaptop2.roam.corp.google.com>  <20141030221501.GA9416@breakpoint.cc> <1414710342.15352.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756368AbaJaJYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2014 05:24:17 -0400
In-Reply-To: <1414710342.15352.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2014 12:05 AM, Eric Dumazet wrote:
> On Thu, 2014-10-30 at 23:15 +0100, Florian Westphal wrote:
>
>> Do you think a fallback to non-ecn for retransmitted syns would help?
>> If not, do you think having ecn tunable available via route is helpful?
>
> Unfortunately some firewalls are buggy and accept a single SYN per flow.
>
> You would need to blacklist ecn at first sign of a possible ecn problem,
> for all following connections attempts.
>
> Note that ECN problems are not only contained in SYN packets being
> eventually dropped. You might have a success to establish a flow, and
> later get CE marks for all packets and cwnd converges to 1.

Wow, that is buggy! Btw, fwiw, there was a recent study [1] (paper
not public yet) which scanned the Alexa's publicly available top
million websites list from a vantage point in US, Europe and Asia:

Half of the Alexa list will now happily use ECN (tcp_ecn=2, most
likely blamed to commit 255cac91c3c9 ;)), the break in connectivity
on-path was found is about 1 in 10,000 cases. Timeouts rather than
receiving back RSTs were much more common in the negotiation phase
(and mostly seen in the Alexa middle band, ranks around 50k-150k):
from 12-thousand hosts on which there _may_ be ECN-linked connection
failures, only 79 failed with RST when _not_ failing with RST when
ECN is not requested.

It's unclear though, how much equipment actually marks the CE, and
as you mention above, marks it correctly ...

> This is really a lot of work to get all sorted out.

Yep, you are right.

  [1] http://ecn.ethz.ch/
