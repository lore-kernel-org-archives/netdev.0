From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 28 Jan 2009 11:50:21 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0901281148540.13825@qirst.com>
References: <20090115183942.GA6325@elte.hu> <200901271213.18605.rusty@rustcorp.com.au> <497E705B.5000302@kernel.org> <200901282108.51864.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	ebiederm@xmission.com, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:35693 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751052AbZA1R1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 12:27:55 -0500
In-Reply-To: <200901282108.51864.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jan 2009, Rusty Russell wrote:

> AFAICT we'll need a hybrid: HAVE_NMISAFE_CPUOPS, and if not, use atomic_t
> in ftrace (which isn't NMI safe on parisc or sparc/32 anyway, but I don't think we care).

Right.


> Other than the shouting, I liked Christoph's system:
> - CPU_INC = always safe (eg. local_irq_save/per_cpu(i)++/local_irq_restore)
> - _CPU_INC = not safe against interrupts (eg. get_cpu/per_cpu(i)++/put_cpu)
> - __CPU_INC = not safe against anything (eg. per_cpu(i)++)
>
> I prefer the name 'local' to the name 'cpu', but I'm not hugely fussed.

The term cpu is meaning multiple things at this point. So yes it may be
better to go with glibc naming of thread local space.

