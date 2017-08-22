From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCHv3 net-next] gre: introduce native tunnel support for ERSPAN
Date: Tue, 22 Aug 2017 08:44:24 -0700
Message-ID: <CALDO+Sbgsm71=KJb=rPgE2Yr2tU+wuTYrV_sKpiRCf5-AoZhmQ@mail.gmail.com>
References: <1503062680-43972-1-git-send-email-u9012063@gmail.com> <20170821.110226.325505016722205417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Meenakshi Vohra <mvohra@vmware.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35727 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933040AbdHVPpF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 11:45:05 -0400
Received: by mail-io0-f179.google.com with SMTP id 1so28291855ioy.2
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 08:45:05 -0700 (PDT)
In-Reply-To: <20170821.110226.325505016722205417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +     struct metadata_dst *tun_dst = NULL;
>> +     const struct iphdr *iph;
>> +     struct erspanhdr *ershdr;
>> +     __be32 index;
>> +     __be32 session_id;
>> +     int len;
>
> Please order local variables from longest to shortest line, ie. reverse
> christmas tree format.
>
thanks for the review, I will fix the ordering in next version.

>> +
>> +     itn = net_generic(net, erspan_net_id);
>> +     iph = ip_hdr(skb);
>> +     len =  iph->ihl * 4 + gre_hdr_len + sizeof(*ershdr);
>> +
>> +     if (unlikely(!pskb_may_pull(skb, len)))
>> +             return -ENOMEM;
>
> I think the len passed here is wrong, it should be
> "gre_hdr_len + sizeof(*ershdr)".

yes, thanks.
The skb->data at this point points to the beginning of GRE header. So
I should check pull of gre + erspan header.

Regards,
William
