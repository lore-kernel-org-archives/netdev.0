From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] lib/dynamic_queue_limits.c: relax BUG_ON to WARN_ON in dql_complete()
Date: Thu, 19 Oct 2017 12:14:26 +0100
Message-ID: <CAKv+Gu_Eg-WD-ej7_KpDTWjYm4KrrJkELTxkNkBdE8a1A2Ht3A@mail.gmail.com>
References: <20171018154515.16751-1-ard.biesheuvel@linaro.org> <20171019.115756.1156159427863267036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:55489 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752108AbdJSLO1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:14:27 -0400
Received: by mail-it0-f66.google.com with SMTP id l196so9310570itl.4
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 04:14:27 -0700 (PDT)
In-Reply-To: <20171019.115756.1156159427863267036.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 October 2017 at 11:57, David Miller <davem@davemloft.net> wrote:
> From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Date: Wed, 18 Oct 2017 16:45:15 +0100
>
>> Even though calling dql_completed() with a count that exceeds the
>> queued count is a serious error, it still does not justify bringing
>> down the entire kernel with a BUG_ON(). So relax it to a WARN_ON()
>> instead.
>>
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>
> This is bogus.
>
> Unless you are going to do all of the work necessary to fix
> the out-of-bounds condition here, you cannot safely continue
> into the rest of this function.
>
> Things are going to explode in many places if you don't, at
> a minimum, fix the 'count' value to be in range.
>
> But like others I don't like this, the driver needs to be fixed
> urgently if this condition triggers.
>
> Sorry I'm not applying this.

Fair enough.
