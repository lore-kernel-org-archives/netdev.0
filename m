From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: sock: move ->sk_shutdown out of bitfields.
Date: Wed, 18 May 2016 10:17:22 -0700
Message-ID: <1463591842.18194.135.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463585471.18194.123.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463588367-16310-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463588367-16310-1-git-send-email-aryabinin@virtuozzo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-05-18 at 19:19 +0300, Andrey Ryabinin wrote:
> ->sk_shutdown bits share one bitfield with some other bits in sock struct,
> such as ->sk_no_check_[r,t]x, ->sk_userlocks ...
> sock_setsockopt() may write to these bits, while holding the socket lock.
> 
> In case of AF_UNIX sockets, we change ->sk_shutdown bits while holding only
> unix_state_lock(). So concurrent setsockopt() and shutdown() may lead
> to corrupting these bits.
> 
> Fix this by moving ->sk_shutdown bits out of bitfield into a separate byte.
> This will not change the 'struct sock' size since ->sk_shutdown moved into
> previously unused 16-bit hole.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
