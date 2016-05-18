From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: af_unix: protect ->sk_shutdown change with
 lock_sock()
Date: Wed, 18 May 2016 12:38:36 +0200
Message-ID: <a070f6f7-ed85-c909-ce8b-748210402211@stressinduktion.org>
References: <1463566486-9123-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:39692 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751891AbcERKij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 06:38:39 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
	by mailout.nyi.internal (Postfix) with ESMTP id 3C3E12193B
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 06:38:38 -0400 (EDT)
In-Reply-To: <1463566486-9123-1-git-send-email-aryabinin@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.05.2016 12:14, Andrey Ryabinin wrote:
> ->sk_shutdown bits share one bitfield with some other bits in sock struct,
> such as ->sk_no_check_[r,t]x, ->sk_userlocks ...
> sock_setsockopt() may write to these bits, while holding the socket lock.
> In case of AF_UNIX sockets, we change ->sk_shutdown bits while holding only
> unix_state_lock(). So concurrent setsockopt() and shutdown() may lead
> to corrupting these bits.
> 
> Fix that by protecting writes to ->sk_shutdown with lock_sock()

Is it possible to move sk_shutdown out of the bitfields? Maybe a whole
which suites is available somewhere?

af_unix doesn't depend on the socket locks anywhere and it would keep
locking much easier if we only depend on the state lock.

Bye,
Hannes
