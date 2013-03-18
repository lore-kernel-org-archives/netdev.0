From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Mon, 18 Mar 2013 12:54:49 -0700
Message-ID: <CAHo-OoxaaLLXtAZcx99m7p5=Hez3gpUWxvoQAgksyG3PRZH-Ng@mail.gmail.com>
References: <1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
	<CANP3RGdZHMTPT6FTbYzSOHkrNq4seF1WcXjysQ6=HEp0A_CxWg@mail.gmail.com>
	<1363601182.4752.13.camel@lb-tlvb-eilong.il.broadcom.com>
	<20130318.131318.138158829629301794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eilong@broadcom.com, eric.dumazet@gmail.com, dmitry@broadcom.com,
	netdev@vger.kernel.org, yuvalmin@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:55926 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab3CRTyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 15:54:50 -0400
Received: by mail-ve0-f178.google.com with SMTP id db10so4711876veb.37
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 12:54:49 -0700 (PDT)
In-Reply-To: <20130318.131318.138158829629301794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've reproduced this in the lab.

I can confirm this patch fixes per-queue statistics (ie. ethtool -S
"[0]: tx_bytes") - which previously were not monotonically increasing.
However there is still a bug wrt. global device stats (ie. ethtool -S
"tx_bytes" and /proc/net/dev transmit bytes).
I'm guessing there's another similar bug later on during aggregation.

I expect to find the offending code and send out a patch soon.

On Mon, Mar 18, 2013 at 10:13 AM, David Miller <davem@davemloft.net> wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Mon, 18 Mar 2013 12:06:22 +0200
>
>> Maciej - thanks for the detailed information. You are right - it has
>> nothing to do with the HW/FW and it is simply a bug that needs to be
>> fixed. I withdraw my objections and add my ACK.
>>
>> Acked-by: Eilon Greenstein <eilong@broadcom.com>
>
> Applied and queued up for -stable.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
