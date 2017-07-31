From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V3 2/2] net: fix tcp reset packet flowlabel for ipv6
Date: Mon, 31 Jul 2017 14:24:28 -0700 (PDT)
Message-ID: <20170731.142428.1731591151245966846.davem@davemloft.net>
References: <63fa4fbb8fc62c958586ef3dd6231794f7c44432.1501518787.git.shli@fb.com>
        <CAM_iQpV-=OxeGyS1ie62x-_+w2pN_V-yxQ0jP3HfjYxo+k_k-A@mail.gmail.com>
        <20170731193027.rbetx7b4jym452mr@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        Kernel-team@fb.com, shli@fb.com, eric.dumazet@gmail.com,
        flo@fourcot.fr
To: shli@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751046AbdGaVYa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 17:24:30 -0400
In-Reply-To: <20170731193027.rbetx7b4jym452mr@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohua Li <shli@kernel.org>
Date: Mon, 31 Jul 2017 12:30:27 -0700

> On Mon, Jul 31, 2017 at 11:10:38AM -0700, Cong Wang wrote:
>> On Mon, Jul 31, 2017 at 10:08 AM, Shaohua Li <shli@kernel.org> wrote:
>> > +/* Like ip6_make_flowlabel, but already has hash */
>> > +static inline __be32 ip6_make_flowlabel_from_hash(struct net *net,
>> > +                                                 bool autolabel, u32 hash)
>> > +{
>> > +       __be32 flowlabel;
>> > +
>> > +       if (net->ipv6.sysctl.auto_flowlabels == IP6_AUTO_FLOW_LABEL_OFF ||
>> > +           (!autolabel &&
>> > +            net->ipv6.sysctl.auto_flowlabels != IP6_AUTO_FLOW_LABEL_FORCED))
>> > +               return 0;
>> > +
>> > +       flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;
>> > +
>> > +       if (net->ipv6.sysctl.flowlabel_state_ranges)
>> > +               flowlabel |= IPV6_FLOWLABEL_STATELESS_FLAG;
>> > +
>> > +       return flowlabel;
>> > +}
>> 
>> I still don't see why you have to duplicate the code,
>> for me you can just refactor ip6_make_flowlabel()
>> and pass the hash as a parameter and pass
>> 'flowlabel' as 0, and no run-time overhead.
> 
> Still need extra check. Ok, I updated the patch.

This is not how you post a new version of a patch.

It is especially not the way to post a new version of a patch which is
part of a series.

You always must make a clean, fresh, patch posting.  Not as a reply to
a discussion email.

And when the patch is part of a series, you must repost the entire
series along with the "[PATCH ... 0/N] " header posting.
