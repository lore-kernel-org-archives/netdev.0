From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] netlink: fix broadcasting to the wrong group.
Date: Tue, 18 Apr 2006 00:21:50 +0400
Message-ID: <20060417202150.GA10764@2ka.mipt.ru>
References: <20060417093632.GA29057@2ka.mipt.ru> <4443B5A8.9010604@trash.net> <20060417194904.GA5237@2ka.mipt.ru> <4443F742.9020508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58261 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750877AbWDQUW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 16:22:28 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4443F742.9020508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 17, 2006 at 10:14:58PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> Evgeniy Polyakov wrote:
> > On Mon, Apr 17, 2006 at 05:35:04PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> > 
> >>This seems to be a misunderstanding, subscribing to groups using bind()
> >>is kept for compatibility and doesn't use group numbers but bitmasks.
> > 
> > 
> > So groups less than 32 are considered as bitmask, and other groups as
> > group numbers, and there is no way to have them consistent and behave
> > like group numbers?
> 
> Not exactly, its not related to the group number. groups used in bind()
> are considered as bitmask and groups used for setsockopt are considered
> as group numbers. We can't change bind() because this behaviour is
> required for compatibility.

So bind and subscribing are almost exclusive and should not be used
simultaneously?

> > But this introduce some problem with subscribing - if one subscribes to
> > group 5 and is bound to the same group it allows to broadcast not only
> > to group 5, and those which have the same bits set, but also to group 16
> > (1<<(5-1)), which has nothing in common with the requested group number.
> 
> Only if you use group numbers for bind(), which is plainly wrong.

Even if one uses group bitmask at bind time and later subscribes to
some group from that bitmask, this will introduce wrong behaviour with
unrelated gropus.
Maybe we should not allow to subscribe if group bitmask different from 1
was used at bind() time?

-- 
	Evgeniy Polyakov
