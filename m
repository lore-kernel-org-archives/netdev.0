From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer
Date: Thu, 06 May 2010 22:10:14 +0200
Message-ID: <1273176614.2222.21.camel@edumazet-laptop>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
	 <1273167155.2853.49.camel@edumazet-laptop>
	 <20100506180233.GB5063@hmsreliant.think-freely.org>
	 <1273170813.2222.10.camel@edumazet-laptop>
	 <20100506195442.GC5063@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:41986 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757130Ab0EFUKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 16:10:21 -0400
Received: by bwz19 with SMTP id 19so213857bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 13:10:19 -0700 (PDT)
In-Reply-To: <20100506195442.GC5063@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Doing that doesn't solve my aim however, which is to avoid performing rt_genid
> updates when no one is attacking you at all.  I completely agree that we can
> start the gen_id at some random value (by forcing an initial invalidation),
> however.  Beyond that however, if someone is managing to guess our secret value,
> then we need to make our secret value more complex to determine.  Perhaps given
> the reduction in the number of times we need to iterate our gen_id with the
> timer gone, we can use something more heavyweight to determine the the hash
> secret (the cprng perhaps?).

Secrets that dont change are known to be honey pots for hackers.

I just dont see why we want to risk security regressions for something
that proved to work well.

Cache invalidation is just a genid change nowadays, and dont have side
effects.

Considering we do cache invalidation when routes are changed anyway, I
dont get why we should avoid the invalidation once every xxx seconds...

If you believe this cache invalidation has problems, maybe we should
address them and not hide them ?



