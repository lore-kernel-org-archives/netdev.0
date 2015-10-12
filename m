From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/7] switchdev: change locking
Date: Mon, 12 Oct 2015 11:52:22 +0200
Message-ID: <20151012095222.GB2370@nanopsycho.orion>
References: <1444576871-19138-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35574 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbbJLJwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 05:52:24 -0400
Received: by wicge5 with SMTP id ge5so143050046wic.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 02:52:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1444576871-19138-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 11, 2015 at 05:21:04PM CEST, jiri@resnulli.us wrote:
>From: Jiri Pirko <jiri@mellanox.com>
>
>This is something which I'm currently struggling with.
>Callers of attr_set and obj_add/del often hold not only RTNL, but also
>spinlock (bridge). So in that case, the driver implementing the op cannot sleep.
>
>The way rocker is dealing with this now is just to invoke driver operation
>and go out, without any checking or reporting of the operation status.
>
>Since it would be nice to at least put a warning in case the operation fails,
>it makes sense to do this in delayed work directly in switchdev core
>instead of implementing this in separate drivers. And that is what this patchset
>is introducing.
>
>So from now on, the locking of switchdev mod ops is consistent. Caller either
>holds rtnl mutex or in case it does not, caller sets defer flag, telling
>switchdev core to process the op later in delayed work.
>
>Flush function for switchdev deferred ops can be called by op
>caller in appropriate location, for example after it releases
>spin lock, to force switchdev core to process pending ops.

Dave, if you are going to apply
"[PATCH net-next v3 0/4] switchdev: push bridge ageing_time attribute down"
first, I have to rebase this patchset on top of that. Just say so.

Thanks!
