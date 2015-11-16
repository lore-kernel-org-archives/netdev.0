From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH net] bpf, arm: start flushing icache range from header
Date: Mon, 16 Nov 2015 12:00:54 +0000
Message-ID: <20151116120053.GF20696@leverpostej>
References: <971980449d680e6b26e273130d74546c5148893c.1447446440.git.daniel@iogearbox.net>
 <20151116114055.GC20696@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nschichan@freebox.fr, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, ast@kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:48797 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbbKPMBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 07:01:00 -0500
Content-Disposition: inline
In-Reply-To: <20151116114055.GC20696@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2015 at 11:40:55AM +0000, Mark Rutland wrote:
> On Sat, Nov 14, 2015 at 01:26:53AM +0100, Daniel Borkmann wrote:
> > During review I noticed that the icache range we're flushing should
> > start at header already and not at ctx.image.
> > 
> > Reason is that after 55309dd3d4cd ("net: bpf: arm: address randomize
> > and write protect JIT code"), we also want to make sure to flush the
> > random-sized trap in front of the start of the actual program (analogous
> > to x86). No operational differences from user side.
> > 
> > Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> > Tested-by: Nicolas Schichan <nschichan@freebox.fr>
> > Cc: Alexei Starovoitov <ast@kernel.org>
> > ---
> >  ( As arm32 fixes usually go via Dave's tree, targeting -net. )
> > 
> >  arch/arm/net/bpf_jit_32.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
> > index 2f4b14c..591f9db 100644
> > --- a/arch/arm/net/bpf_jit_32.c
> > +++ b/arch/arm/net/bpf_jit_32.c
> > @@ -1061,7 +1061,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
> >  	}
> >  	build_epilogue(&ctx);
> >  
> > -	flush_icache_range((u32)ctx.target, (u32)(ctx.target + ctx.idx));
> > +	flush_icache_range((u32)header, (u32)(ctx.target + ctx.idx));
> 
> As with the arm64 patch, doesn't this prevent us from flushing the end
> of the image? ctx.idx doesn't seem to take into account the header size.

I'd misread the patch; it is fine.

Sorry for the noise.

Mark.
