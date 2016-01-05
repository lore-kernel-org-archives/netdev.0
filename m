From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH v4 net-next 3/4] soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
Date: Tue, 5 Jan 2016 10:47:05 -0500
Message-ID: <CAEfhGixhapu3CGStGMhiba4tBhzfNJcKe2BwJYR7RNPx7gfXoQ@mail.gmail.com>
References: <1451947308-7867-1-git-send-email-kraigatgoog@gmail.com>
	<1451947308-7867-4-git-send-email-kraigatgoog@gmail.com>
	<568B8F18.2050706@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36629 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbcAEPrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 10:47:08 -0500
Received: by mail-lf0-f50.google.com with SMTP id z124so291417395lfa.3
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 07:47:07 -0800 (PST)
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com. [209.85.215.52])
        by smtp.gmail.com with ESMTPSA id l129sm2807663lfl.37.2016.01.05.07.47.05
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 07:47:05 -0800 (PST)
Received: by mail-lf0-f52.google.com with SMTP id y184so296354932lfc.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 07:47:05 -0800 (PST)
In-Reply-To: <568B8F18.2050706@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 5, 2016 at 4:38 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 01/04/2016 11:41 PM, Craig Gallek wrote:
>>
>> From: Craig Gallek <kraig@google.com>
>>
>> Expose socket options for setting a classic or extended BPF program
>> for use when selecting sockets in an SO_REUSEPORT group.  These options
>> can be used on the first socket to belong to a group before bind or
>> on any socket in the group after bind.
>>
>> This change includes refactoring of the existing sk_filter code to
>> allow reuse of the existing BPF filter validation checks.
>>
>> Signed-off-by: Craig Gallek <kraig@google.com>
>
> [...]
>>
>> +static struct sock *run_bpf(struct sock_reuseport *reuse, u16 socks,
>> +                           struct bpf_prog *prog, struct sk_buff *skb,
>> +                           int hdr_len)
>> +{
>> +       struct sk_buff *nskb = NULL;
>> +       u32 index;
>> +
>> +       if (skb_shared(skb)) {
>> +               nskb = skb_clone(skb, GFP_ATOMIC);
>> +               if (!nskb)
>> +                       return NULL;
>> +               skb = nskb;
>> +       }
>> +
>> +       /* temporarily advance data past protocol header */
>> +       if (!pskb_pull(skb, hdr_len)) {
>> +               consume_skb(nskb);
>
>
> Btw, this one could still be made kfree_skb() to indicate error condition
> here.
Good point.  I'll send a follow-up.
