From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCHv2 net-next] gre: introduce native tunnel support for ERSPAN
Date: Thu, 17 Aug 2017 15:34:30 -0700
Message-ID: <CALDO+SbOmOkKjfE=CNOc-SjBdbFfD26uit9Me7UXWQj+kyiaKw@mail.gmail.com>
References: <1502311986-36324-1-git-send-email-u9012063@gmail.com> <20170813.195347.1798002797313374893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Meenakshi Vohra <mvohra@vmware.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:37769 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752632AbdHQWfL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 18:35:11 -0400
Received: by mail-it0-f42.google.com with SMTP id 76so420940ith.0
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 15:35:10 -0700 (PDT)
In-Reply-To: <20170813.195347.1798002797313374893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> +static int erspan_rcv(struct sk_buff *skb, struct tnl_ptk_info *tpi,
>> +                   int gre_hdr_len)
>> +{
>> +     struct net *net = dev_net(skb->dev);
>> +     struct ip_tunnel_net *itn;
>> +     struct ip_tunnel *tunnel;
>> +     struct metadata_dst *tun_dst = NULL;
>> +     const struct iphdr *iph;
>> +     struct erspanhdr *ershdr;
>> +     __be32 index;
>> +     __be32 session_id;
>> +
>> +     itn = net_generic(net, erspan_net_id);
>> +     iph = ip_hdr(skb);
>> +     ershdr = (struct erspanhdr *)(skb->data + gre_hdr_len);
>
> You're not guaranteed the this ershdr area is pulled linearly in the
> SKB.  Only the GRE header and it's options have that guarantee.
>
> So you'll need to add appropriate pskb_may_pull() checks here then
> reaload all of the packet pointers (including 'iph') afterwards.

Thanks, I will make the change and resubmit.
Regards,
William
