From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: Tue, 16 Jul 2013 10:20:40 -0700
Message-ID: <CAP6odjgHcQ3Q6j_XSaLm0iJkAx+8tgtN+psXUekQ9U55O+9zjg@mail.gmail.com>
References: <20130712180116.21176.qmail@science.horizon.com>
	<1373932689.3745.30.camel@bwh-desktop.uk.level5networks.com>
	<CAP6odjjyXqhMBAY3L1p7w9UPU2VH04MsyaWG6wb1YB_Pe43Dyg@mail.gmail.com>
	<1373985465.2120.1.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: George Spelvin <linux@horizon.com>, eric.dumazet@gmail.com,
	Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:46633 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519Ab3GPRUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 13:20:41 -0400
Received: by mail-oa0-f41.google.com with SMTP id n10so1219460oag.14
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 10:20:41 -0700 (PDT)
In-Reply-To: <1373985465.2120.1.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 16, 2013 at 7:37 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Mon, 2013-07-15 at 18:17 -0700, Grant Grundler wrote:
...
>> Is the problem the reference to skb->len?
>> By passing ownership,  are you suggesting the device can change this value?
>
> No, the device can complete the descriptor and then the TX completion
> handler will free the skb.

Ah ok. That's what the spinlock_irqsave() is protecting against.

> [...]
>> > But one day someone may want to get rid of this lock,
>> > so this is a trap waiting to spring.
>>
>> Even for tulip driver?  Sorry, I just can't imagine anyone taking
>> enough interest in tulip driver to implement that.  I'm not even sure
>> it would be possible.
>
> You're taking interest in it, aren't you?

Let me clarify my interest: I will reject patches to change the
locking for this driver. Patch reviews for this driver are a
"community service project" since I know reasonably well how this chip
behaves. But I'm not doing anything else (e.g. bug fixes or testing).

If someone else wants to change the tulip driver locking, they need to
submit a patch to become the new maintainer first (I'll ACK that :)

>  But I accept this is a minor issue.

Ok.

cheers,
grant
