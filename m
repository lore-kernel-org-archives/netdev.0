From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH] net/tun: fix ioctl() based info leaks
Date: Mon, 30 Jul 2012 07:38:37 +0200
Message-ID: <CA+rthh9WDNAvDQz-3nzCWhRX97j7B79i61eax0GSNPV4nkUZSQ@mail.gmail.com>
References: <1343595494-10414-1-git-send-email-minipli@googlemail.com>
	<CAFLxGvwUNxOn3vRLdJeS6hVZ_Oko0_QPZfLWAe+ztCHGdqBFOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59845 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab2G3Fii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 01:38:38 -0400
Received: by pbbrp8 with SMTP id rp8so9245054pbb.19
        for <netdev@vger.kernel.org>; Sun, 29 Jul 2012 22:38:37 -0700 (PDT)
In-Reply-To: <CAFLxGvwUNxOn3vRLdJeS6hVZ_Oko0_QPZfLWAe+ztCHGdqBFOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 30, 2012 at 1:11 AM, richard -rw- weinberger
<richard.weinberger@gmail.com> wrote:
> On Sun, Jul 29, 2012 at 10:58 PM, Mathias Krause <minipli@googlemail.com> wrote:
>> -       if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
>> +       if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89) {
>>                 if (copy_from_user(&ifr, argp, ifreq_len))
>>                         return -EFAULT;
>> +       } else {
>> +               memset(&ifr, 0, sizeof(ifr));
>> +       }
>>
>>         if (cmd == TUNGETFEATURES) {
>>                 /* Currently this just means: "what IFF flags are valid?".
>
> The fix makes sense to me.
>
> Beside of the fix, why are you adding braces to if and else?

The pair of braces around the "if" is needed to attach the "else"
branch to the right "if". The braces around the "else" are just for
consistency.

> We don't use braces on single statements.

Even tun.c isn't consistently following this rule but I'll send a new
patch without the "else" braces.


Thanks,
Mathias
