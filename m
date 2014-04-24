From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 5/5] net: filter: optimize BPF migration
 for ARG1/CTX handling
Date: Thu, 24 Apr 2014 16:04:29 -0400 (EDT)
Message-ID: <20140424.160429.890390197318316554.davem@davemloft.net>
References: <1398321927-8845-1-git-send-email-dborkman@redhat.com>
	<1398321927-8845-6-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbaDXUEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 16:04:31 -0400
In-Reply-To: <1398321927-8845-6-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 24 Apr 2014 08:45:27 +0200

> Currently, at initial setup in __sk_run_filter() we initialize the
> BPF stack's frame-pointer and CTX register. However, instead of the
> CTX register, we initialize context to ARG1, and during user filter
> migration we emit *always* an instruction that copies the content
> from ARG1 over to CTX. ARG1 is needed in BPF_CALL instructions to
> setup ctx; for user BPF filter ARG2 has A, and ARG3 X for call
> emission. However, we nevertheless copy CTX over to ARG1 in these
> cases for user migrated filters. We can spare us this extra interpreter
> instruction and assign it during initial setup time.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

We're adjust code for facilities that aren't even used.

I want someone to explain to me exactly how calls in and out of
the EBPF context are expected to behave.

There are so many cpu calling conventions.  Some use registers up
to a certain number for passing arguments, then any overflow args
go on the stack.  Some pass all args on the stack.

How will all such schemes be accomodated by the BPF_CALL facilities?

Until I personally can even begin to understand this, I'm not applying
any more patches to these areas of the code, sorry.
