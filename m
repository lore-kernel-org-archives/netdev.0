From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Thu, 29 Jan 2009 10:48:43 -0800
Message-ID: <4981FA0B.5010101@zytor.com>
References: <20090115183942.GA6325@elte.hu> <200901271213.18605.rusty@rustcorp.com.au> <497E705B.5000302@kernel.org> <200901282108.51864.rusty@rustcorp.com.au> <alpine.DEB.1.10.0901281148540.13825@qirst.com> <20090128180757.GA9908@Krystal> <alpine.DEB.1.10.0901291315320.9622@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, brgerst@gmail.com,
	ebiederm@xmission.com, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:35124 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbZA2Ste (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 13:49:34 -0500
In-Reply-To: <alpine.DEB.1.10.0901291315320.9622@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> 
> gcc/glibc support a __thread attribute to variables. As far as I can tell
> this automatically makes gcc perform the relocation to the current
> context using a segment register.
> 
> But its a weird ABI http://people.redhat.com/drepper/tls.pdf. After
> reading that I agree that we should stay with the cpu ops and forget about
> the local and thread stuff in gcc/glibc.
> 

We have discussed this a number of times.  There are several issues with
it; one being that per-cpu != per-thread (we can switch CPU whereever
we're preempted), and another that many versions of gcc uses hardcoded
registers, in particular %fs on 64 bits, but the kernel *has* to use %gs
since there is no swapfs instruction.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

