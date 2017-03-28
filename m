From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipconfig: fix ic_close_devs() use-after-free
Date: Mon, 27 Mar 2017 21:07:24 -0700 (PDT)
Message-ID: <20170327.210724.753199024787667111.davem@davemloft.net>
References: <1490634014-23098-1-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, jmorris@namei.org, kaber@trash.net,
        netdev@vger.kernel.org
To: mark.rutland@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdC1EHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 00:07:35 -0400
In-Reply-To: <1490634014-23098-1-git-send-email-mark.rutland@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rutland <mark.rutland@arm.com>
Date: Mon, 27 Mar 2017 18:00:14 +0100

> Our chosen ic_dev may be anywhere in our list of ic_devs, and we may
> free it before attempting to close others. When we compare d->dev and
> ic_dev->dev, we're potentially dereferencing memory returned to the
> allocator. This causes KASAN to scream for each subsequent ic_dev we
> check.
> 
> As there's a 1-1 mapping between ic_devs and netdevs, we can instead
> compare d and ic_dev directly, which implicitly handles the !ic_dev
> case, and avoids the use-after-free. The ic_dev pointer may be stale,
> but we will not dereference it.
> 
> Original splat:
 ...
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>

Applied, thanks.
