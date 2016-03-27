From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] net: sxgbe: fix error paths in sxgbe_platform_probe()
Date: Sun, 27 Mar 2016 23:40:24 +0200
Message-ID: <87r3ev8urb.fsf@rasmusvillemoes.dk>
References: <877fgue1mx.fsf@rasmusvillemoes.dk>
	<1459027449-2667-1-git-send-email-linux@rasmusvillemoes.dk>
	<20160327082254.GA10620@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33738 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbcC0Vk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 17:40:27 -0400
Received: by mail-wm0-f41.google.com with SMTP id l68so80422731wml.0
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 14:40:27 -0700 (PDT)
In-Reply-To: <20160327082254.GA10620@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Sun, 27 Mar 2016 10:22:54 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 27 2016, Francois Romieu <romieu@fr.zoreil.com> wrote:

> Rasmus Villemoes <linux@rasmusvillemoes.dk> :
>> We need to use post-decrement to ensure that irq_dispose_mapping is
>> also called on priv->rxq[0]->irq_no; moreover, if one of the above for
>> loops failed already at i==0 (so we reach one of these labels with
>> that value of i), we'll enter an essentially infinite loop of
>> out-of-bounds accesses.
>> 
>> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
>
> (ok, i is signed)
>
> Reviewed-by: Francois Romieu <romieu@fr.zoreil.com>
>

Thanks for reviewing, but just FTR I want to point out that it doesn't
matter whether i is signed or not in

  while (i--)

However, when i is signed, there's another slightly less popular variant
which is equivalent:

  while (--i >= 0)

(a precondition for their equivalence is that i has a non-negative value
before reaching the while statement).

Neither are equivalent to the almost-always broken

  while (--i)

Rasmus
