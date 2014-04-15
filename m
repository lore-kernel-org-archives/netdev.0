From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] filter: added BPF random opcode
Date: Tue, 15 Apr 2014 07:41:34 -0700
Message-ID: <1397572894.4222.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397516569-31033-1-git-send-email-chema@google.com>
	 <534CDE99.6090407@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chema Gonzalez <chema@google.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	ast@plumgrid.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:50377 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423AbaDOOlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 10:41:36 -0400
Received: by mail-pa0-f53.google.com with SMTP id ld10so9656289pab.40
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 07:41:35 -0700 (PDT)
In-Reply-To: <534CDE99.6090407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-15 at 09:24 +0200, Daniel Borkmann wrote:

> > @@ -773,6 +779,7 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
> >   	case SKF_AD_OFF + SKF_AD_NLATTR:
> >   	case SKF_AD_OFF + SKF_AD_NLATTR_NEST:
> >   	case SKF_AD_OFF + SKF_AD_CPU:
> > +	case SKF_AD_OFF + SKF_AD_RANDOM:
> 
> I think instead of a function call, this sould rather be modelled
> directly into the internal insn set and thus converted differently,
> so we can spare us the call.

Hmmm... this would need percpu storage, thus preempt disable/enable
calls, and prandom_u32_state() is about 40 instructions.

This is really not worth the pain.
