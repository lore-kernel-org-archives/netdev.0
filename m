From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2 00/12] bnxt_en: Add XDP support.
Date: Fri, 3 Feb 2017 13:58:56 -0800
Message-ID: <CALx6S35rQa25soEiidnK12pbBPGcuhsE_Nr-epYNL-P+srwSOg@mail.gmail.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
 <20170203.154910.2213640966872850071.davem@davemloft.net> <CACKFLimXCkC1=9kvQnz-s5rjTOGe1gmb9Ozvt1tEeW+O=y7yAg@mail.gmail.com>
 <20170203.165054.437855043325795801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Chan <michael.chan@broadcom.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35911 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752452AbdBCV65 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:58:57 -0500
Received: by mail-qt0-f193.google.com with SMTP id h53so7214192qth.3
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 13:58:57 -0800 (PST)
In-Reply-To: <20170203.165054.437855043325795801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 1:50 PM, David Miller <davem@davemloft.net> wrote:
> From: Michael Chan <michael.chan@broadcom.com>
> Date: Fri, 3 Feb 2017 13:13:47 -0800
>
>> On Fri, Feb 3, 2017 at 12:49 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>> Please _DO NOT_ guard XDP support with an ifdef the user
>>> can modify.
>>>
>>> Treat it like any other common netdev feature a driver might
>>> support such as checksum offloading or GRO.
>>>
>>
>> David, I want to make sure I understand completely.  Are you saying
>> don't use Kconfig option for XDP?  Have it always available?
>
> Yes.
>
> I don't see a similar config option used in any other driver.
>
> What's really driving me completely mad about driver XDP adoption
> is that there is so much inconsistency.
>
> If you do not see another XDP supporting driver do something, don't be
> tempted to blaze your own trail and handle something in a unique way.
>
> We don't set precedence by one driver saying "hey it's better to do
> things this way, forget what all the other drivers are doing."  Rather
> we have a "discussion" about what the appropriate thing is to do and
> convert all the drivers only after a decision has been made.
>
> Meanwhile we keep the status quo.

I am working on some API changes that will hopefully get a little
consistency across these drivers (this includes feature flag
NETIF_F_XDP). This will reduce code some and should be good cleanup,
but XDP is currently very intertwined with the critical data path so
we might need to be looking at this for a while. There's now more
drivers with XDP support than when I started this work, so I don't
think bnxt should wait for this cleanup-- it's just one more driver
we'll have to retrofit.

Tom
