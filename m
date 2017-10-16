From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/3] bpf: Don't check for current being NULL
Date: Mon, 16 Oct 2017 15:31:07 -0700
Message-ID: <20171016223105.c3ww4nf5kvrseebh@ast-mbp.dhcp.thefacebook.com>
References: <CAADnVQJzM3DH_gxAwo2mnGiv7bOsip1TAFF8YGPLx-dqSb1SPQ@mail.gmail.com>
 <1838884.qlCOuH57mO@blindfold>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ftp.linux.org.uk>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>, linux-arch@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:44131 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756899AbdJPWbK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 18:31:10 -0400
Content-Disposition: inline
In-Reply-To: <1838884.qlCOuH57mO@blindfold>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 12:23:13AM +0200, Richard Weinberger wrote:
> Alexei,
> 
> Am Dienstag, 17. Oktober 2017, 00:06:08 CEST schrieb Alexei Starovoitov:
> > On Mon, Oct 16, 2017 at 11:18 AM, Richard Weinberger <richard@nod.at> wrote:
> > > current is never NULL.
> > > 
> > > Signed-off-by: Richard Weinberger <richard@nod.at>
> > > ---
> > > 
> > >  kernel/bpf/helpers.c | 12 ------------
> > >  1 file changed, 12 deletions(-)
> > > 
> > > diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
> > > index 3d24e238221e..e8845adcd15e 100644
> > > --- a/kernel/bpf/helpers.c
> > > +++ b/kernel/bpf/helpers.c
> > > @@ -120,9 +120,6 @@ BPF_CALL_0(bpf_get_current_pid_tgid)
> > > 
> > >  {
> > >  
> > >         struct task_struct *task = current;
> > > 
> > > -       if (unlikely(!task))
> > > -               return -EINVAL;
> > > -
> > 
> > really? in all context? including irq and nmi?
> 
> I would be astonished current is NULL in such a context.
> 
> To be sure, let's CC linux-arch.
> IIRC I talked also with Al about this and he also assumed that current
> cannot be NULL.

Hmm I probably mistakenly stole the !current check from somewhere.
Happy to delete all these checks then.
