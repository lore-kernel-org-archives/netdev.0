From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Thu, 3 Dec 2015 14:15:13 -0200
Message-ID: <20151203161513.GC4164@mrl.redhat.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
 <20151203130525.GB4164@mrl.redhat.com>
 <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
 <CANn89iKEv-q6EFi1eX+Hk_2+jNfZ0ayUqUn_Fh1U7RTs9xjdXg@mail.gmail.com>
 <CACT4Y+bgeqS05zqkAHkxzAP7fuvFSkeEybwDTizw6Gp8KK28Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33497 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757175AbbLCQPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 11:15:17 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+bgeqS05zqkAHkxzAP7fuvFSkeEybwDTizw6Gp8KK28Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 03, 2015 at 04:55:44PM +0100, Dmitry Vyukov wrote:
> On Thu, Dec 3, 2015 at 3:48 PM, Eric Dumazet <edumazet@google.com> wrote:
> >>
> >> No, I don't. But pr_debug always computes its arguments. See no_printk
> >> in printk.h. So this use-after-free happens for all users.
> >
> > Hmm.
> >
> > pr_debug() should be a nop unless either DEBUG or CONFIG_DYNAMIC_DEBUG are set
> >
> > On our production kernels, pr_debug() is a nop.
> >
> > Can you double check ? Thanks !
> 
> 
> Why should it be nop? no_printk thing in printk.h pretty much
> explicitly makes it not a nop...
> 
> Double-checked: debug_post_sfx leads to some generated code:

Oups. I was under that impression too, that it would do sanity-check
while being optimized out.

I'll think on a fix for this.

Thanks,
  Marcelo
