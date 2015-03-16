From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: [PATCH net-next v2] Configure bridge FDB ageing time using netlink.
Date: Mon, 16 Mar 2015 12:12:39 +0530
Message-ID: <CA+CtxLTzqDh98bPQBS9AGdoi_-2=jSrnSJN3CL2bHE5nVoZ-cQ@mail.gmail.com>
References: <1426297229-21122-1-git-send-email-siva.mannem.lnx@gmail.com>
	<20150315.221312.1089494260964314644.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:36284 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbCPGml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 02:42:41 -0400
Received: by wetk59 with SMTP id k59so30938823wet.3
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 23:42:40 -0700 (PDT)
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

Agree. Will work on it. Can it be a follow-on patch?

-- 
Regards,
Siva Mannem.
