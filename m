From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC 05/12] nfp: add BPF to NFP code translator
Date: Wed, 1 Jun 2016 22:23:13 +0100
Message-ID: <20160601222313.4be2de9c@jkicinski-Precision-T1700>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
	<1464799814-4453-6-git-send-email-jakub.kicinski@netronome.com>
	<574F3F78.1010606@iogearbox.net>
	<20160601201546.GA22759@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	ast@kernel.org, dinan.gunawardena@netronome.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:33055 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbcFAVXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 17:23:37 -0400
Received: by mail-wm0-f42.google.com with SMTP id s131so416115wme.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 14:23:36 -0700 (PDT)
In-Reply-To: <20160601201546.GA22759@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Jun 2016 13:15:48 -0700, Alexei Starovoitov wrote:
> On Wed, Jun 01, 2016 at 10:03:04PM +0200, Daniel Borkmann wrote:
> > On 06/01/2016 06:50 PM, Jakub Kicinski wrote:  
> > >Add translator for JITing eBPF to operations which
> > >can be executed on NFP's programmable engines.
> > >
> > >Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > >Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> > >Reviewed-by: Simon Horman <simon.horman@netronome.com>  
> > [...]  
> > >+int
> > >+nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem, unsigned int prog_start,
> > >+	    unsigned int tgt_out, unsigned int tgt_abort,
> > >+	    unsigned int prog_sz, struct nfp_bpf_result *res)
> > >+{
> > >+	struct nfp_prog *nfp_prog;
> > >+	int ret;
> > >+
> > >+	/* TODO: maybe make this dependent on bpf_jit_enable? */  
> > 
> > Probably makes sense to leave it independent from this.
> > 
> > Maybe that would rather be an ethtool flag/setting?  
> 
> Agree that it should be independent of bpf_jit_enable,
> since that's very different JIT. The whole point of hw offload
> is that bpf is translated into something hw understand natively.
> Gating it by sysctl or another flag doesn't make much sense to me.
> In this case the user will say 'do offload tc+cls_bpf into a nic'
> and nic should either do it or not. No need for ethtool flag either.
> One can argue that that bpf_jit_enable=2 was useful for debugging
> of JIT itself, but looks like it was only used by jit developers
> like us, but we would be fine with temp printk while debugging.
> At least there was never a case where jit had a bug and we would
> ask a person reporting a bug to send us back jit_enable=2 output.
> We cannot remove it now, but I wouldn't simply copy the behavior here.
> So I'm suggesting not to use bpf_jit_enable either 1 or 2 at all.

That clarifies things a lot, thanks!  I was indeed mostly hoping to use
this to control debug prints, but as you said those are mostly useful
for the developers so I didn't even include the debug/trace infra here.
