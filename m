From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC] netns: keep vlan slaves on master netns move
Date: Fri, 17 Sep 2010 14:49:15 +0200
Message-ID: <4C9363CB.7050302@trash.net>
References: <20100824115056.GA235835@jupiter.n2.diac24.net>	<20100913114315.GA859019@jupiter.n2.diac24.net> <m1bp7z4v0m.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	David Lamparter <equinox@diac24.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40402 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159Ab0IQMtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 08:49:20 -0400
In-Reply-To: <m1bp7z4v0m.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 15.09.2010 04:10, schrieb Eric W. Biederman:
> 
> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> My inclination is that the best way to handle this is to would be to
> push the device deletion for vlan and macvlan devices into the device
> core, where we could get the advantage of batched deletions.

We've added batched deletion to both about a year ago, what exactly
is the problem?

>  Right
> now vlan and macvlan devices are the only devices I know of that cause
> other devices to be removed during unregister, so removing that
> specialness seems reasonable.

Actually all devices can cause this when used as a lower device by
vlan or macvlan. Both vlan and macvlan are useless without a lower
device, so I don't see why we shouldn't remove them when the lower
device is unregistered.

> However not being able to move the primary vlan to a different network
> namespace is usability bug with no real alternatives.  There are
> not any other patches on the table right now, and your patch below
> seems obviously correct.  Let's get this merged before we forget about
> this, bug fix.

Looks reasonable to me.

Acked-by: Patrick McHardy <kaber@trash.net>
