From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 23:19:03 -0800
Message-ID: <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
References: <1447879416.562854.443622857.62708268@webmail.messagingengine.com>
	<20151118.224919.452852815199526735.davem@davemloft.net>
	<CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	<20151119.005318.838757439536205791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Colitti <lorenzo@google.com>, hannes@stressinduktion.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	stephen@networkplumber.org, Linux NetDev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33051 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757871AbbKSHTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 02:19:04 -0500
Received: by igvi2 with SMTP id i2so5786440igv.0
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 23:19:03 -0800 (PST)
In-Reply-To: <20151119.005318.838757439536205791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What I object to is userspace making reachability decisions, not
> whether SOCK_DESTROY closes the socket in one way or the other.

Privileged userspace can already make these decisions today, whether
it is by killing processes with open sockets, or by turning interfaces
up and down or by reconfiguring the firewall and/or the routing
rules/tables, or by injecting spoofed TCP reset packets (via tap).
It's just *very* inconvenient to do and error prone.

Another example: privileged userspace could ptrace the userspace apps
and via code injection call close() on the app's behalf and reopen the
file descriptor to some null routed destination so it behaves like if
it was timed out / unreachable.

In general the statement that (appropriately privileged) 'userspace
should not be able to do something' is wrong - about the only
exception I can think of being crashing the machine or burning the
hardware.

The kernel's purpose in life should be to enable userspace to do things.

You make things too hard for people to do stuff via the kernel and you
end up with the kernel being out of a job.  People either implement
things entirely in userspace (userspace tcp stacks on raw sockets or
tap or udp) or switch to a different kernel or create a local fork...

I'm not saying the proposed solution is ideal (although honestly it
doesn't seem bad), but this problem does deserve a clean *kernel*
solution instead of insane userspace hacks or non vanilla Linux
patches which then propagate to a billion devices...
