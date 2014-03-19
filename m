From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH] net : Remove unnecessary assignments
Date: Wed, 19 Mar 2014 10:23:16 +0530
Message-ID: <CAHPKR9KeEcfgD2ZJOJFzEEMKdXH2Kqtc_O4k9Ot5XrB60T+60A@mail.gmail.com>
References: <53287010.8000703@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E0472@AcuExch.aculab.com>
	<1395162206.2812.56.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Laight <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46990 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164AbaCSExR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 00:53:17 -0400
Received: by mail-we0-f174.google.com with SMTP id t60so6499555wes.5
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 21:53:16 -0700 (PDT)
In-Reply-To: <1395162206.2812.56.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David and Joe for clarifications

Regards,
K.Balakumaran

On Tue, Mar 18, 2014 at 10:33 PM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2014-03-18 at 16:22 +0000, David Laight wrote:
>> From: Behalf Of Balakumaran Kannan
>> > Remove unnecessary assignments
>> >
>> > Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
>> > ---
>> > Some unnecessary assignments has been removed from devinet_ioctl function.
>> > The 'ret' variable is set in multiple places, but used only based on if
>> > conditions. So keeping the assignment inside if will be a better.
>> ...
>>
>> These all seem to be this transform:
>> > -   ret = -ENODEV;
>> >     dev = __dev_get_by_name(net, ifr.ifr_name);
>> > -   if (!dev)
>> > +   if (!dev) {
>> > +           ret = -ENODEV;
>> >             goto done;
>> > +   }
>>
>> I bet that if you look at the generated code you'll find
>> that the compiler generates the same code for both forms
>> and is likely to generate the equivalent of:
>>       dev = __dev_get_by_name(net, ifr.ifr_name);
>>       ret = -ENODEV;
>>       if (!dev)
>>               goto done;
>>
>> So this is just a matter of style.
>
> Yabut it's Linus' preferred style.
> http://lkml.org/lkml/2008/12/16/383
>
> (but not mine, I prefer what's done by the patch)
>
>
