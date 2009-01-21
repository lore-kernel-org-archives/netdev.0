From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 21 Jan 2009 23:45:01 +1100
Message-ID: <20090121234502.66acbcf9@s6510>
References: <20090115183942.GA6325@elte.hu>
	<200901170827.33729.rusty@rustcorp.com.au>
	<20090116220832.GB20653@elte.hu>
	<200901201328.24605.rusty@rustcorp.com.au>
	<20090120104022.GB29346@elte.hu>
	<4976B82E.1080002@kernel.org>
	<m1fxjcucp8.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	cl@linux-foundation.org, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50043 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758961AbZAUMp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2009 07:45:56 -0500
In-Reply-To: <m1fxjcucp8.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jan 2009 03:21:23 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Tejun Heo <tj@kernel.org> writes:
> 
> > Ingo Molnar wrote:
> >> The larger point still remains: the kernel dominantly uses static percpu 
> >> variables by a margin of 10 to 1, so we cannot just brush away the static 
> >> percpu variables and must concentrate on optimizing that side with 
> >> priority. It's nice if the dynamic percpu-alloc side improves as well, of 
> >> course.
> >
> > Well, the infrequent usage of dynamic percpu allocation is in some
> > part due to the poor implementation, so it's sort of chicken and egg
> > problem.  I got into this percpu thing because I wanted a percpu
> > reference count which can be dynamically allocated and it sucked.
> 
> Counters are our other special case, and counters are interesting
> because they are individually very small.  I just looked and the vast
> majority of the alloc_percpu users are counters.
> 
> I just did a rough count in include/linux/snmp.h  and I came
> up with 171*2 counters.  At 8 bytes per counter that is roughly
> 2.7K.  Or about two thirds of a 4K page.

This is crap. only a small fraction of these SNMP counters are
close enough to the hot path to deserve per-cpu treatment.
