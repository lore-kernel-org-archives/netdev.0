From: Patrick McHardy <kaber@trash.net>
Subject: Re: [1/1] netlink: fix broadcasting to the wrong group.
Date: Mon, 17 Apr 2006 22:14:58 +0200
Message-ID: <4443F742.9020508@trash.net>
References: <20060417093632.GA29057@2ka.mipt.ru> <4443B5A8.9010604@trash.net> <20060417194904.GA5237@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:26579 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750724AbWDQUPA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 16:15:00 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060417194904.GA5237@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Mon, Apr 17, 2006 at 05:35:04PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> 
>>This seems to be a misunderstanding, subscribing to groups using bind()
>>is kept for compatibility and doesn't use group numbers but bitmasks.
> 
> 
> So groups less than 32 are considered as bitmask, and other groups as
> group numbers, and there is no way to have them consistent and behave
> like group numbers?

Not exactly, its not related to the group number. groups used in bind()
are considered as bitmask and groups used for setsockopt are considered
as group numbers. We can't change bind() because this behaviour is
required for compatibility.

> But this introduce some problem with subscribing - if one subscribes to
> group 5 and is bound to the same group it allows to broadcast not only
> to group 5, and those which have the same bits set, but also to group 16
> (1<<(5-1)), which has nothing in common with the requested group number.

Only if you use group numbers for bind(), which is plainly wrong.
