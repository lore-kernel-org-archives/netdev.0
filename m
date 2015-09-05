From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 6/6] ebpf: allow BPF_REG_X in src_reg conditional jumps
Date: Fri, 4 Sep 2015 21:12:52 -0700
Message-ID: <20150905041249.GA2066@Alexeis-MBP-2.westell.com>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-7-git-send-email-tycho.andersen@canonical.com>
 <20150904210619.GF1842@Alexeis-MacBook-Pro-2.local>
 <20150904224350.GU26679@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33524 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbbIEEM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 00:12:56 -0400
Content-Disposition: inline
In-Reply-To: <20150904224350.GU26679@smitten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 04, 2015 at 04:43:50PM -0600, Tycho Andersen wrote:
> > The fix should be something like this:
> > diff --git a/net/core/filter.c b/net/core/filter.c
> > index 13079f03902e..05a04ea87172 100644
> > --- a/net/core/filter.c
> > +++ b/net/core/filter.c
> > @@ -478,9 +478,9 @@ do_pass:
> >                                 bpf_src = BPF_X;
> >                         } else {
> >                                 insn->dst_reg = BPF_REG_A;
> > -                               insn->src_reg = BPF_REG_X;
> >                                 insn->imm = fp->k;
> >                                 bpf_src = BPF_SRC(fp->code);
> > +                               insn->src_reg = bpf_src == BPF_X ? BPF_REG_X : 0;
> >                         }
> 
> Yep, I just tested this and it works for me. Do you want to manage it
> or should I carry it as part of this set?

Though it's a bug, it doesn't affect anything at the moment
and not worth fixing in net, so please submit it as separate bug
fix when net-next reopens. imo the rest of the patches should
also go via net-next to minimize cross-tree conflicts.
