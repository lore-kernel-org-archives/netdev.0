From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 1/2] syncookies: do not store rcv_wscale in tcp
 timestamp
Date: Wed, 23 Jun 2010 22:28:00 +0200
Message-ID: <20100623202759.GA3581@nuttenaction>
References: <1277156925-7295-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:45743 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752666Ab0FWU2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 16:28:03 -0400
Content-Disposition: inline
In-Reply-To: <1277156925-7295-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Florian Westphal | 2010-06-21 23:48:44 [+0200]:

>As pointed out by Fernando Gont there is no need to encode rcv_wscale
>into the cookie.
>
>We did not use the restored rcv_wscale anyway; it is recomputed
>via tcp_select_initial_window().

I speculate that this behavior was and is not correct. I suppose that their is
a race between the SYN/ACK where we initial force a particular window scale
and the next time where we recalculate the window via tcp_select_initial_window().

If the user change net.core.rmem_max or net.ipv4.tcp_rmem in between this
time, the recalculated window scale (rcv_wscale) can be smaller. But the
receiver still operates with the initial window scale and can overshot the
granted window - and bang.

There are several solutions: encode rcv_wscale into the syn cookie and don't
recalculate or disable window scaling and don't transmit any scaling option
when SYN cookies are active.

HGN
