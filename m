From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 1/2] bpf: remove struct bpf_prog_type_list
Date: Mon, 10 Apr 2017 07:42:23 +0200
Message-ID: <1491802943.2455.1.camel@sipsolutions.net>
References: <20170407190008.32632-1-johannes@sipsolutions.net>
         <20170409.182236.865920818973965236.davem@davemloft.net>
         <20170410022357.GB17150@ast-mbp.thefacebook.com>
         (sfid-20170410_042404_005156_918EEB46)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:33048 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751087AbdDJFmb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 01:42:31 -0400
In-Reply-To: <20170410022357.GB17150@ast-mbp.thefacebook.com> (sfid-20170410_042404_005156_918EEB46)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > If you just don't want to list things multiple times how about:
> > 
> > linux/bpf_verifiers.h:
> > BPF_VERIFIER(BPF_PROG_TYPE_SOCKET_FILTER, sk_filter_prog_ops)
> > BPF_VERIFIER(BPF_PROG_TYPE_SCHED_CLS, tc_cls_prog_ops)
> >  ...
> > 
> > Then in bpf.h:
> > 
> > #define BPF_VERIFIER(TYPE_VAL, SYM) extern const struct
> > bpf_verifier_ops SYM;
> > #include <linux/bpf_verifiers.h"
> > 
> > and in kernel/bpf/syscall.c:
> > 
> > #define BPF_VERIFIER(TYPE_VAL, SYM) [TYPE_VAL] = &SYM,
> > #include <linux/bpf_verifiers.h"
> > 
> > or something like that.
> 
> That is great suggestion! I like it.

It'd doable, but then I need to play with the include guards, like
having "#define __BPF_REINCLUDE" or something like that before
reincluding it, I guess? Unless that file can simply not be included
anywhere?

Maybe I'll play with it - though perhaps it should be named bpf_types.h
or something like that so we don't have to have two files.

johannes
