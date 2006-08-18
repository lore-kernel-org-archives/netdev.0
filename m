From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Fri, 18 Aug 2006 16:44:01 -0700
Message-ID: <44E650C1.80608@google.com>
References: <20060808211731.GR14627@postel.suug.ch>	<44DBED4C.6040604@redhat.com>	<44DFA225.1020508@google.com>	<20060813.165540.56347790.davem@davemloft.net>	<44DFD262.5060106@google.com>	<20060813185309.928472f9.akpm@osdl.org>	<1155530453.5696.98.camel@twins>	<20060813215853.0ed0e973.akpm@osdl.org>	<44E3E964.8010602@google.com>	<20060816225726.3622cab1.akpm@osdl.org>	<44E5015D.80606@google.com>	<20060817230556.7d16498e.akpm@osdl.org>	<44E62F7F.7010901@google.com> <20060818153455.2a3f2bcb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	David Miller <davem@davemloft.net>, riel@redhat.com,
	tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:43395 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1750799AbWHRXrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 19:47:33 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060818153455.2a3f2bcb.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> ...in my earlier emails I asked a number of questions regarding
> whether existing facilities, queued patches or further slight kernel
> changes could provide a sufficient solution to these problems.  The answer
> may well be "no".  But diligence requires that we be able to prove that,
> and handwaving doesn't provide that proof, does it?

Hi Andrew,

I missed those questions about queued patches.  So far the closest we
have seen to anything relevant is Evgeniy's proposed network sub-allocater,
which just doesn't address the problem, as Peter and I have explained in
some detail, and the dirty page throttling machinery which is obviously
flawed in that it leaves a lot of room for corner cases that have to be
handled with more special purpose logic.  For example, what about kernel
users that just go ahead and use lots of slab without getting involved
in the dirty/mapped page accounting?  I don't know, maybe you will handle
that too, but then there will be another case that isn't handled, and so
on.  The dirty page throttling approach is just plain fragile by nature.

We already know we need to do reserve accounting for struct bio, so what
is the conceptual difficulty in extending that reasoning to struct
sk_buff, which is very nearly the same kind of beastie, performing very
nearly the same kind of function, and suffering very nearly the same kind
of problems we had in the block layer before mingo's mempool machinery
arrived?

Did I miss some other queued patch that bears on this?  And I am not sure
what handwaving you are referring to.

Note that we have not yet submitted this patch to the queue, just put
it up for comment.  This patch set is actually getting more elegant as
various individual artists get their flames in.  At some point it will
acquire a before-and-after test case as well, then we can realistically
compare it to the best of the alternate proposals.

Regards,

Daniel
