From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: [PATCH net-next v2] Configure bridge FDB ageing time using netlink.
Date: Mon, 16 Mar 2015 13:29:16 +0530
Message-ID: <CA+CtxLR-mWy_R7P-YqQwT+R20dBr-8OicvTji5-vbtFa1vzarg@mail.gmail.com>
References: <1426297229-21122-1-git-send-email-siva.mannem.lnx@gmail.com>
	<20150315.221312.1089494260964314644.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34003 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbbCPH7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 03:59:17 -0400
Received: by wibg7 with SMTP id g7so25606582wib.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 00:59:16 -0700 (PDT)
In-Reply-To: <20150315.221312.1089494260964314644.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 7:43 AM, David Miller <davem@davemloft.net> wrote:
> From: Siva Mannem <siva.mannem.lnx@gmail.com>
> Date: Sat, 14 Mar 2015 07:10:29 +0530
>
>> This patch allows user to configure bridge's FDB ageing using
>> netlink(for ex, iproute2). Allowed range is 10 seconds to 1000000 seconds
>> as per ieee8021QBridgeFdbAgingTime.
>>
>> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
>
> The behavior of br_changelink() leaves a lot to be desired, and this
> change is making it worse.
>
> The range of the netlink attributes, the only thing that can cause
> an error, should be validated for all attributes _first_.
>
I will check whether this can be achieved by adding the required range checks
to br_validate(). Any side-effects with this approach?

> Because right now you can have several values change state,
> then the last one has a range error, and an error is returned
> without rolling back the state.
>

> This is terrible.
>
> When this happens the user has not reliable way to figure out
> that some of the state changes it requested happened, and
> exactly which ones those were.
>
> If an error is thrown we _MUST_ not make any state changes to
> the bridge whatsoever.



-- 
Regards,
Siva Mannem.
