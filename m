From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in the
 list
Date: Thu, 08 Jan 2015 06:51:11 -0800
Message-ID: <1420728671.5947.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miller <davem@davemloft.net>
To: Dennis Chen <kernel.org.gnu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:41482 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218AbbAHOvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 09:51:14 -0500
Received: by mail-ig0-f169.google.com with SMTP id z20so2876792igj.0
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 06:51:13 -0800 (PST)
In-Reply-To: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-08 at 16:22 +0800, Dennis Chen wrote:
> Some drivers may clear the NAPI_STATE_SCHED bit upon the state of the
> NAPI instance after exhaust the budget in the poll function, which
> will open a window for next device interrupt handler to insert a same
> instance to the list after calling list_add_tail(&n->poll_list,
> repoll) if we don't set this bit.
> 
> Signed-off-by: Dennis Chen <kernel.org.gnu@gmail.com>
> ---


Well no.

I am removing some atomic ops in the stack, please do not add new ones,
especially if no driver is that buggy.

The unlikely() wont help the expensive stuff being done here.
