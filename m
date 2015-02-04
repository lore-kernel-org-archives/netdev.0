From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net v4] net: ipv6: allow explicitly choosing optimistic addresses
Date: Wed, 4 Feb 2015 20:53:31 +0900
Message-ID: <CAKD1Yr1+49qoJC5HURKfrUDyEO7Z+LtLAq0AVb9jMofoM4WEfg@mail.gmail.com>
References: <1423047683-16267-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:52046 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228AbbBDLxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 06:53:52 -0500
Received: by mail-ie0-f175.google.com with SMTP id ar1so1325963iec.6
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 03:53:51 -0800 (PST)
In-Reply-To: <1423047683-16267-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 8:01 PM, Erik Kline <ek@google.com> wrote:
> +               /* Decouple optimistic from tentative for evaluation here.
> +                * Ban optimistic addresses explicitly, when required.
> +                */

I don't find this comment particularly useful, but I suppose there's
no harm in having it.

> +               ifp_flags = (ifp->flags&IFA_F_OPTIMISTIC)
> +                           ? (ifp->flags&~IFA_F_TENTATIVE)
> +                           : ifp->flags;
>                 if (ipv6_addr_equal(&ifp->addr, addr) &&
> -                   !(ifp->flags&IFA_F_TENTATIVE) &&
> +                   !(ifp_flags&banned_flags) &&
>                     (dev == NULL || ifp->idev->dev == dev ||

That looks correct now. It's also nicer than what I had proposed.

Adding the new ipv6_chk_addr_and_flags function is definitely less
churn than the alternative of updating all the callers of
ipv6_chk_addr (19 files) to pass in the extra argument. Not sure which
is preferred, the churn or the new function.

Acked-by: Lorenzo Colitti <lorenzo@google.com>
