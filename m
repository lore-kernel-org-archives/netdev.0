From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net v2] net: ipv6: allow explicitly choosing optimistic addresses
Date: Thu, 29 Jan 2015 14:25:51 +0900
Message-ID: <CAKD1Yr2LJT+rYwbKQMvMQFtSDTwQAHk5k__m22J=kx8eKxj1JA@mail.gmail.com>
References: <1422446619-9502-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:60002 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbbA2F0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 00:26:12 -0500
Received: by mail-ie0-f177.google.com with SMTP id vy18so29352068iec.8
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 21:26:11 -0800 (PST)
In-Reply-To: <1422446619-9502-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2015 at 9:03 PM, Erik Kline <ek@google.com> wrote:
>                 if (ipv6_addr_equal(&ifp->addr, addr) &&
> -                   !(ifp->flags&IFA_F_TENTATIVE) &&
> +                   (!(ifp->flags&banned_flags) ||
> +                    ifp->flags&IFA_F_OPTIMISTIC&~banned_flags) &&

Is this if statement correct?

The intent here is "if ifp has IFA_F_OPTIMISTIC set, then
IFA_F_TENTATIVE is allowed, even if the caller explicitly banned
IFA_F_TENTATIVE", right? Not "if ifp has IFA_F_OPTIMISTIC set, then
any flags are allowed, even ones explicitly baned by the caller". For
example, suppose that:

    banned_flags = IFA_F_SECONDARY
    ifp->flags = IFA_F_SECONDARY | IFA_F_OPTIMISTIC

In that case, won't the if statement match ifp, even though it
contains a flag that is explicitly banned?
