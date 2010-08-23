From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 21:57:43 +0200
Message-ID: <20100823195742.GA5896@nuttenaction>
References: <1282590037-18566-1-git-send-email-hagen@jauu.net>
 <20100823121449.29419771@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:45806 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754244Ab0HWT5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 15:57:54 -0400
Content-Disposition: inline
In-Reply-To: <20100823121449.29419771@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger | 2010-08-23 12:14:49 [-0700]:

>If this is configurable (still not sure about having yet more
>TCP knobs). It should either be per-socket or a route metric so it can
>be controlled on a per-path basis.

Hello Stephen,

I thought about this too. But IMHO it makes no sense because interactive/bulk
characteristic do not depend on the "path". Rather it depends on application
level. Furthermore, how should an administrator configure this on a per path
basis? The administrator knows that he runs a WEB server - great . And then
SHOULD disable Quick ACK and everything is fine, think about typical server
setup.

The only remunerating alternative is to disable TCP quick ACK at all for the
_first_ server ACK. So that the standard delayed ACK is active and therefore
the mechanism can detect if the flow is interactive or not. The drawback is
that for bulk data flows the first ACK is "artificial" delayed. This is the
superior solution IMHO.

Anyway, I think that for most server setup these days (HTTP, SMTP, ...) the
TCP Quick ACK mechanism is contra-productive. Vanilla bulk data transfer
protocols are rarer these days.

Hagen

