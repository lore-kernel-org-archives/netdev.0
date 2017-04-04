From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] bpf: use 'ctx' instead of 'skb' in debug message
Date: Tue, 04 Apr 2017 19:30:10 +0200
Message-ID: <1491327010.26929.2.camel@sipsolutions.net>
References: <20170404144608.27382-1-johannes@sipsolutions.net>
         <58E3D73B.5050806@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37842 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753254AbdDDRaO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 13:30:14 -0400
In-Reply-To: <58E3D73B.5050806@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-04 at 19:26 +0200, Daniel Borkmann wrote:

> >   	if (regs[BPF_REG_6].type != PTR_TO_CTX) {
> > -		verbose("at the time of BPF_LD_ABS|IND R6 !=
> > pointer to skb\n");
> > +		verbose("at the time of BPF_LD_ABS|IND R6 !=
> > pointer to ctx\n");
> >   		return -EINVAL;
> 
> Seems okay, the reason why we had 'skb' in the verbose message here
> is due to BPF_LD + BPF_ABS/BPF_IND operations being only specific to
> skbs and no other context (see __bpf_prog_run(), and in verifier
> may_access_skb() check before that verbose() message in
> check_ld_abs()). Reason for this is mostly historical due to the cBPF
> to eBPF migration so that these loads don't get slowed down when
> migrated to eBPF and can be handled by JIT optimizations (e.g.,
> caching skb->data), too. Anyway, just to provide some more background
> on this. I've no strong opinion if you want to change the verifier
> error message, so:

Ah. I really have no opinion on this either - it just seemed somewhat
inconsistent. I clearly neglected to read the comment in front of the
function though, that explains that we must have ctx == skb. I think
therefore it's probably better to drop this - thanks for the
explanation!

johannes
