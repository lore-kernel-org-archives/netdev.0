From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC 03/12] net: cls_bpf: limit hardware offload by
 software-only flag
Date: Wed, 1 Jun 2016 22:05:20 +0100
Message-ID: <20160601220520.717fb5f8@jkicinski-Precision-T1700>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
	<1464799814-4453-4-git-send-email-jakub.kicinski@netronome.com>
	<574F3A27.5050208@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org,
	dinan.gunawardena@netronome.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33791 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbcFAVFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 17:05:25 -0400
Received: by mail-wm0-f48.google.com with SMTP id s131so347884wme.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 14:05:25 -0700 (PDT)
In-Reply-To: <574F3A27.5050208@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Jun 2016 21:40:23 +0200, Daniel Borkmann wrote:
> > diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
> > index f4297c8a42fe..93a86edf3bd8 100644
> > --- a/include/uapi/linux/pkt_cls.h
> > +++ b/include/uapi/linux/pkt_cls.h
> > @@ -395,6 +395,7 @@ enum {
> >   	TCA_BPF_FD,
> >   	TCA_BPF_NAME,
> >   	TCA_BPF_FLAGS,
> > +	TCA_BPF_GEN_TCA_FLAGS,  
> 
> Small nit for the non-RFC set: I'd simply name that TCA_BPF_FLAGS_GEN.

OK!

> > @@ -400,8 +406,11 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
> >
> >   		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
> >   	}
> > +	if (tb[TCA_BPF_GEN_TCA_FLAGS])
> > +		gen_flags = nla_get_u32(tb[TCA_BPF_GEN_TCA_FLAGS]);
> >
> >   	prog->exts_integrated = have_exts;
> > +	prog->gen_flags = gen_flags & CLS_BPF_SUPPORTED_GEN_FLAGS;  
> 
> Invalid flags should probably be rejected here with -EINVAL or something.

Indeed, that would be more in line with what is done for "the other"
flags attribute, but not so much with how flower and u32 handles
flags. I like the stricter approach better, though, so unless someone
speaks up I'll do as you suggest.
