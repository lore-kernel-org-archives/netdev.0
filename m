From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Wed, 18 May 2011 15:26:53 -0400 (EDT)
Message-ID: <20110518.152653.1486764697527722925.davem@davemloft.net>
References: <1305619677.2850.11.camel@edumazet-laptop>
	<1305715384-81716-1-git-send-email-tsunanet@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tsunanet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benoit Sigoure <tsunanet@gmail.com>
Date: Wed, 18 May 2011 03:43:04 -0700

> Instead of hardcoding the initial RTO to 3s and requiring
> the kernel to be recompiled to change it, expose it as a
> sysctl that can be tuned at runtime.  Leave the default
> value unchanged.
> 
> Signed-off-by: Benoit Sigoure <tsunanet@gmail.com>

If you read the ietf draft that reduces the initial RTO down to 1
second, it states that if we take a timeout during the initial
connection handshake then we have to revert the RTO back up to 3
seconds.

This fallback logic conflicts with being able to only change the
initial RTO via sysctl, I think.  Because there are actually two
values at stake and they depend upon eachother, the initial RTO and
the value we fallback to on initial handshake retransmissions.

So I'd rather get a patch that implements the 1 second initial
RTO with the 3 second fallback on SYN retransmit, than this patch.

We already have too many knobs.
