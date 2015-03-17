From: Ulf Samuelsson <netdev@emagii.com>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Wed, 18 Mar 2015 00:33:56 +0100
Message-ID: <5508B9E4.1060507@emagii.com>
References: <1426107673-45049-1-git-send-email-netdev@emagii.com> <20150312.142621.1128728353472907283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxf3.bahnhof.se ([213.80.101.27]:61016 "EHLO mxf3.bahnhof.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933AbbCQXeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 19:34:08 -0400
In-Reply-To: <20150312.142621.1128728353472907283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Den 2015-03-12 19:26, David Miller skrev:
> I hate changes like this.
>
> By making this a Kconfig options it cannot be dynamic, and every
> distribution is going to have to scratch their head and decide
> what to set this to.
>
> That's seriously suboptimal.
>
> If you want to change behavior based upon whether userspace is
> managing the damn table, make it so the user doing so has to
> ask for the new behavior at _RUN TIME_ via the netlink interface
> or similar.
>
> Picking the guard time itself at compile time is also undesirable.
>
> And you don't even want a damn timer, what you want is for the
> state of the entry to be frozen and for the user to "release"
> it by either adjusting the state to something else or marking
> in some other way to allow it to be unfrozen and released again.
>
> Why put it to chance with some timeout?  Make things explicit.
>
> I'm not applying this patch.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Sounds reasonable comments to me.

Would this approach work?

2 new message types are defined, to enable/disable the garbage
collection functionality.

RTM_ENANEIGHGC
RTM_DISANEIGHGC


When the functionality is disabled, the stack will not garbage collect,
and the external application will have to send netlink messages
to delete unwanted entries.

1 new message is defined to move an entry from STALE to DELAY.
RTM_NEIGHRECOVER

Will have to discuss internally to see if this works.

BR
Ulf Samuelsson
