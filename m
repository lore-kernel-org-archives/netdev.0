From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] netlink: fix broadcasting to the wrong group.
Date: Mon, 17 Apr 2006 23:49:05 +0400
Message-ID: <20060417194904.GA5237@2ka.mipt.ru>
References: <20060417093632.GA29057@2ka.mipt.ru> <4443B5A8.9010604@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43211 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750802AbWDQTtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 15:49:15 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4443B5A8.9010604@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 17, 2006 at 05:35:04PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> This seems to be a misunderstanding, subscribing to groups using bind()
> is kept for compatibility and doesn't use group numbers but bitmasks.

So groups less than 32 are considered as bitmask, and other groups as
group numbers, and there is no way to have them consistent and behave
like group numbers?
But this introduce some problem with subscribing - if one subscribes to
group 5 and is bound to the same group it allows to broadcast not only
to group 5, and those which have the same bits set, but also to group 16
(1<<(5-1)), which has nothing in common with the requested group number.

-- 
	Evgeniy Polyakov
