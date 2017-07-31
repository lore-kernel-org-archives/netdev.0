From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net V3 2/2] net: fix tcp reset packet flowlabel for ipv6
Date: Mon, 31 Jul 2017 11:10:38 -0700
Message-ID: <CAM_iQpV-=OxeGyS1ie62x-_+w2pN_V-yxQ0jP3HfjYxo+k_k-A@mail.gmail.com>
References: <0ffd86784b6bc5209d592ea57c0b14f51bfbdc24.1501518787.git.shli@fb.com>
 <63fa4fbb8fc62c958586ef3dd6231794f7c44432.1501518787.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        kernel-team <Kernel-team@fb.com>, Shaohua Li <shli@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Florent Fourcot <flo@fourcot.fr>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33642 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750940AbdGaSK7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 14:10:59 -0400
Received: by mail-wm0-f68.google.com with SMTP id q189so25796142wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 11:10:59 -0700 (PDT)
In-Reply-To: <63fa4fbb8fc62c958586ef3dd6231794f7c44432.1501518787.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 10:08 AM, Shaohua Li <shli@kernel.org> wrote:
> +/* Like ip6_make_flowlabel, but already has hash */
> +static inline __be32 ip6_make_flowlabel_from_hash(struct net *net,
> +                                                 bool autolabel, u32 hash)
> +{
> +       __be32 flowlabel;
> +
> +       if (net->ipv6.sysctl.auto_flowlabels == IP6_AUTO_FLOW_LABEL_OFF ||
> +           (!autolabel &&
> +            net->ipv6.sysctl.auto_flowlabels != IP6_AUTO_FLOW_LABEL_FORCED))
> +               return 0;
> +
> +       flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;
> +
> +       if (net->ipv6.sysctl.flowlabel_state_ranges)
> +               flowlabel |= IPV6_FLOWLABEL_STATELESS_FLAG;
> +
> +       return flowlabel;
> +}

I still don't see why you have to duplicate the code,
for me you can just refactor ip6_make_flowlabel()
and pass the hash as a parameter and pass
'flowlabel' as 0, and no run-time overhead.

Or I am missing anything?
