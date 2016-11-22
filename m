From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer
 before dereferncing it
Date: Tue, 22 Nov 2016 11:28:37 -0800
Message-ID: <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com>
References: <1479824726-62607-1-git-send-email-roid@mellanox.com>
 <20161122144844.GB1819@nanopsycho> <58346C7B.7090006@iogearbox.net> <20161122161159.GC1819@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Roi Dayan <roid@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Cong Wang <cwang@twopensource.com>,
        John Fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34745 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933641AbcKVT27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 14:28:59 -0500
Received: by mail-io0-f195.google.com with SMTP id r94so1905662ioe.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 11:28:58 -0800 (PST)
In-Reply-To: <20161122161159.GC1819@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 8:11 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Nov 22, 2016 at 05:04:11PM CET, daniel@iogearbox.net wrote:
>>Hmm, I don't think we want to have such an additional test in fast
>>path for each and every classifier. Can we think of ways to avoid that?
>>
>>My question is, since we unlink individual instances from such tp-internal
>>lists through RCU and release the instance through call_rcu() as well as
>>the head (tp->root) via kfree_rcu() eventually, against what are we protecting
>>setting RCU_INIT_POINTER(tp->root, NULL) in ->destroy() callback? Something
>>not respecting grace period?
>
> If you call tp->ops->destroy in call_rcu, you don't have to set tp->root
> to null.

We do need to respect the grace period if we touch the globally visible
data structure tp in tcf_destroy(). Therefore Roi's patch is not fixing the
right place.

Also I don't know why you blame my commit, this problem should already
exist prior to my commit, probably date back to John's RCU patches.

I am working on a patch.
