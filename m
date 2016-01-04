From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH v3 net-next 3/4] soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
Date: Mon, 4 Jan 2016 17:35:58 -0500
Message-ID: <CAEfhGixFuGUpUgYDvUoGA-_ot5JzVF7egFxVqyRcibhjxTWoyA@mail.gmail.com>
References: <1451924798-15136-1-git-send-email-kraigatgoog@gmail.com>
	<1451924798-15136-4-git-send-email-kraigatgoog@gmail.com>
	<20160104201149.GA33051@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f195.google.com ([209.85.217.195]:34936 "EHLO
	mail-lb0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbcADWgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 17:36:01 -0500
Received: by mail-lb0-f195.google.com with SMTP id tz10so17373328lbb.2
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 14:36:00 -0800 (PST)
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com. [209.85.217.171])
        by smtp.gmail.com with ESMTPSA id h187sm9001307lfg.18.2016.01.04.14.35.58
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 14:35:58 -0800 (PST)
Received: by mail-lb0-f171.google.com with SMTP id oh2so166187002lbb.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 14:35:58 -0800 (PST)
In-Reply-To: <20160104201149.GA33051@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 4, 2016 at 3:11 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Jan 04, 2016 at 11:26:37AM -0500, Craig Gallek wrote:
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
> ...
>> +     /* temporarily advance data past protocol header */
>> +     if (!pskb_may_pull(skb, hdr_len) || !pskb_pull(skb, hdr_len)) {
>> +             consume_skb(nskb);
>> +             return NULL;
>> +     }
>
> pskb_pull() includes pskb_may_pull().
Thanks, I completely missed this :\  -> v4
