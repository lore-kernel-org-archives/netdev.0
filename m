From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Tue, 20 Jan 2009 15:25:50 +0900
Message-ID: <49756E6E.2060409@kernel.org>
References: <20090115183942.GA6325@elte.hu> <200901170827.33729.rusty@rustcorp.com.au> <20090116220832.GB20653@elte.hu> <200901201328.24605.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	ebiederm@xmission.com, cl@linux-foundation.org, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:59346 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752890AbZATG00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 01:26:26 -0500
In-Reply-To: <200901201328.24605.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> The generic versions Tejun posted are not softirq safe, so not
> suitable for network counters. To figure out what semantics we
> really want we need to we must audit the users; I'm sorry I haven't
> finished that task (and won't until after the conference).

No, they're not.  They're preempt safe as mentioned in the comment and
is basically just generalization of the original x86 versions used by
x86_64 on SMP before pda and percpu areas were merged.  I agree that
it's something very close to local_t and it would be nice to see those
somehow unified (and I have patches which make use of local_t in my
queue waiting for dynamic percpu allocation).

Another question to ask is whether to keep using separate interfaces
for static and dynamic percpu variables or migrate to something which
can take both.

Thanks.

-- 
tejun
