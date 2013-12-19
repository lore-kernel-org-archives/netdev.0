From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH] net: fec: fix potential use after free
Date: Thu, 19 Dec 2013 14:05:28 -0600
Message-ID: <CAHrpEqQre+Y=+m-RX9nADA2Z7NirxYH0yKCwMSZpnn2GKx0jkw@mail.gmail.com>
References: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131219193231.GB14612@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:45212 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711Ab3LSUF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:05:29 -0500
Received: by mail-we0-f179.google.com with SMTP id q59so1558487wes.24
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 12:05:28 -0800 (PST)
In-Reply-To: <20131219193231.GB14612@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 1:32 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Thu, Dec 19, 2013 at 10:53:02AM -0800, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> skb_tx_timestamp(skb) should be called _before_ TX completion
>> has a chance to trigger, otherwise it is too late and we access
>> freed memory.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Fixes: de5fb0a05348 ("net: fec: put tx to napi poll function to fix dead lock")
>
> So the hw_lock spin lock was protecting against this issue?
>
> Nice catch. How ever did you find this?

I think It is not related with hw_lock.  After trigger transfer,
there are possibility that tx completed immediately and irq handle
will free skb.

>
> Acked-by: Richard Cochran <richardcochran@gmail.com>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
