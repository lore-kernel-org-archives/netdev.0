From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 2/2] net: systemport: fix UniMAC reset logic
Date: Tue, 24 Jun 2014 16:16:16 -0700
Message-ID: <CAGVrzcaquiXbkt0HtEuyOqq+9os+5P8Hh=UezFdmNZo=w=LZYQ@mail.gmail.com>
References: <1403294500-31905-1-git-send-email-f.fainelli@gmail.com>
 <1403294500-31905-3-git-send-email-f.fainelli@gmail.com> <20140624.161241.1533958645479291631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:35899 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbaFXXQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 19:16:57 -0400
Received: by mail-ob0-f177.google.com with SMTP id uy5so1123386obc.8
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 16:16:56 -0700 (PDT)
In-Reply-To: <20140624.161241.1533958645479291631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-24 16:12 GMT-07:00 David Miller <davem@davemloft.net>:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Fri, 20 Jun 2014 13:01:40 -0700
>
>> The UniMAC CMD_SW_RESET bit is not a self-clearing bit, so we need to
>> assert it, wait a bit and clear it manually. As a result, umac_reset()
>> is updated not to return any value.
>>
>> By setting CMD_SW_RESET and only that bit, we were also clearing the
>> other 31 bits, overriding the hardware reset defaults which are
>> correctly set on purpose.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>
> I agree with Sergei, this is really suspicious that the existing code
> never wrote the sw reset bit into the register at all, it just writes
> a zero.
>
> And you don't mention this at all in this commit message.
>
> If I were to guess, I would fathom that the sequence was partially
> copied from the other broadcom driver, the genet one.  There it
> issues CMD_SW_RESET by first clearing the entire regiser to zero,
> then writing CMD_SW_RESET, and then polling for that bit to clear.
>
> I'm assuming that is being done for a good reason, and I'd like
> you to make sure that same reason does not apply here.

I'll resubmit with a proper explanation, thanks.
-- 
Florian
