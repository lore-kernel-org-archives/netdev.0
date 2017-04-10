From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 1/2] bpf: remove struct bpf_prog_type_list
Date: Sun, 9 Apr 2017 19:23:59 -0700
Message-ID: <20170410022357.GB17150@ast-mbp.thefacebook.com>
References: <20170407190008.32632-1-johannes@sipsolutions.net>
 <20170409.182236.865920818973965236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
        johannes.berg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35069 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbdDJCYD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 22:24:03 -0400
Received: by mail-pg0-f68.google.com with SMTP id g2so23807491pge.2
        for <netdev@vger.kernel.org>; Sun, 09 Apr 2017 19:24:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170409.182236.865920818973965236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 09, 2017 at 06:22:36PM -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Fri,  7 Apr 2017 21:00:07 +0200
> 
> > From: Johannes Berg <johannes.berg@intel.com>
> > 
> > There's no need to have struct bpf_prog_type_list since
> > it just contains a list_head, the type, and the ops
> > pointer. Since the types are densely packed and not
> > actually dynamically registered, it's much easier and
> > smaller to have an array of type->ops pointer. Also
> > initialize this array statically to remove code needed
> > to initialize it.
> > 
> > Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> 
> If you just don't want to list things multiple times how about:
> 
> linux/bpf_verifiers.h:
> BPF_VERIFIER(BPF_PROG_TYPE_SOCKET_FILTER, sk_filter_prog_ops)
> BPF_VERIFIER(BPF_PROG_TYPE_SCHED_CLS, tc_cls_prog_ops)
>  ...
> 
> Then in bpf.h:
> 
> #define BPF_VERIFIER(TYPE_VAL, SYM) extern const struct bpf_verifier_ops SYM;
> #include <linux/bpf_verifiers.h"
> 
> and in kernel/bpf/syscall.c:
> 
> #define BPF_VERIFIER(TYPE_VAL, SYM) [TYPE_VAL] = &SYM,
> #include <linux/bpf_verifiers.h"
> 
> or something like that.

That is great suggestion! I like it.
