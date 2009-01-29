From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Thu, 29 Jan 2009 13:33:13 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0901291315320.9622@qirst.com>
References: <20090115183942.GA6325@elte.hu> <200901271213.18605.rusty@rustcorp.com.au> <497E705B.5000302@kernel.org> <200901282108.51864.rusty@rustcorp.com.au> <alpine.DEB.1.10.0901281148540.13825@qirst.com> <20090128180757.GA9908@Krystal>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <tj@kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	ebiederm@xmission.com, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:51145 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751785AbZA2TQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:16:09 -0500
In-Reply-To: <20090128180757.GA9908@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jan 2009, Mathieu Desnoyers wrote:

> > The term cpu is meaning multiple things at this point. So yes it may be
> > better to go with glibc naming of thread local space.
> >
>
> However using "local" for "per-cpu" could be confusing with the glibc
> naming of thread local space, because "per-thread" and "per-cpu"
> variables are different from a synchronization POV and we can end up
> needing both (e.g. a thread local variable can never be accessed by
> another thread, but a cpu local variable could be accessed by a
> different CPU due to scheduling).

gcc/glibc support a __thread attribute to variables. As far as I can tell
this automatically makes gcc perform the relocation to the current
context using a segment register.

But its a weird ABI http://people.redhat.com/drepper/tls.pdf. After
reading that I agree that we should stay with the cpu ops and forget about
the local and thread stuff in gcc/glibc.

