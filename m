From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Reported regression against commit a05d2ad
Date: Tue, 21 Jun 2011 13:49:45 -0700
Message-ID: <m1oc1qnc46.fsf@fess.ebiederm.org>
References: <20110621201528.GB2249@herton-IdeaPad-Y430>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lamont@canonical.com, sconklin@canonical.com,
	tim.gardner@canonical.com, netdev@vger.kernel.org
To: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52133 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757558Ab1FUUtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 16:49:50 -0400
In-Reply-To: <20110621201528.GB2249@herton-IdeaPad-Y430> (Herton Ronaldo
	Krzesinski's message of "Tue, 21 Jun 2011 17:15:29 -0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com> writes:

> Hi,
>
> after update to one of the latest 2.6.32.x stable kernels for Ubuntu, we
> got a regression report about timeout in tcp connections
> (https://launchpad.net/bugs/791512).
>
> We tried help reporter with a bisect process, but it was taking some
> time, so we reverted some suspect commits, until we isolated it to
> commit "af_unix: Only allow recv on connected seqpacket sockets."
>
> With only commit a05d2ad reverted, testing results so far indicate the
> issue doesn't happen.
>
> I'm unfamiliar with unix sockets code, so can't see at first why this
> commit in particular is causing problems, for now I can only say may be
> something at application level using unix sockets regressed with it (?).
> I'm just reporting it right now, and we plan to revert it for that kernel
> until more info is found about it.

The only thing commit a05d2ad will prevent is a non-sense use of a
af_unix socket, and on recent enough kernels a NULL pointer deference.

I respectfully suggest that the bug is elsewhere perhaps a broken user
space application out there that needs to be fixed, or you have a kernel
memory stomp that removing patch a05d2ad happens to shift the memory
layout to be harmful in a different way.

af_unix sockets have nothing to do with tcp and only happen to use
the TCP_ESTABLISHED flag to indicated connected or non-connected
sockets.

Eric

> I'm adding reporter to CC (Lamont), in case more details are necessary
> etc.
