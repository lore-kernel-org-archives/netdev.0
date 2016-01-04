From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
Date: Mon, 4 Jan 2016 11:22:24 -0500
Message-ID: <CAEfhGiwiuJv+qBgNS8ObbJExBnbjyH=dWw5tLWpc_FcBdemKHQ@mail.gmail.com>
References: <1451410150-15466-1-git-send-email-kraigatgoog@gmail.com>
	<1451410150-15466-4-git-send-email-kraigatgoog@gmail.com>
	<20151229235057.GA5396@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34172 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbcADQW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 11:22:26 -0500
Received: by mail-lf0-f67.google.com with SMTP id n70so10802769lfn.1
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 08:22:26 -0800 (PST)
Received: from mail-lf0-f42.google.com (mail-lf0-f42.google.com. [209.85.215.42])
        by smtp.gmail.com with ESMTPSA id f186sm4563738lfd.26.2016.01.04.08.22.24
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 08:22:24 -0800 (PST)
Received: by mail-lf0-f42.google.com with SMTP id p203so280480170lfa.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 08:22:24 -0800 (PST)
In-Reply-To: <20151229235057.GA5396@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2015 at 6:50 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Dec 29, 2015 at 12:29:09PM -0500, Craig Gallek wrote:
>> From: Craig Gallek <kraig@google.com>
>> +static struct sock *run_bpf(struct sock_reuseport *reuse, u16 socks,
>> +                         struct bpf_prog *prog, struct sk_buff *skb,
>> +                         int hdr_len)
>> +{
>> +     struct sk_buff *nskb = NULL;
>> +     u32 index;
>> +
>> +     if (skb_shared(skb)) {
>> +             nskb = skb_clone(skb, GFP_ATOMIC);
>> +             if (!nskb)
>> +                     return NULL;
>> +             skb = nskb;
>> +     }
>> +
>> +     /* temporarily advance data past protocol header */
>> +     if (!pskb_may_pull(skb, hdr_len) || !skb_pull_inline(skb, hdr_len)) {
>
> pskb_pull() would be cleaner.
ACK -> v3

>> +             consume_skb(nskb);
>> +             return NULL;
>> +     }
>> +     index = bpf_prog_run_save_cb(prog, skb);
>> +     __skb_push(skb, hdr_len);
>
> This indeed matches what normal bpf filters see with udp sockets, so
> I guess that's fine.
> Acked-by: Alexei Starovoitov <ast@kernel.org>
Thanks for the review!
