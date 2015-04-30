From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [PATCH net-next 3/3] tcp: invoke pkts_acked hook on every ACK
Date: Fri, 1 May 2015 00:20:32 +0200
Message-ID: <CA++eYdsdW9emVJbiWnCwK5a7STPLsun2X-2edZkpYHEt6KpA6A@mail.gmail.com>
References: <1430411012-4939-1-git-send-email-kennetkl@ifi.uio.no>
	<1430411012-4939-3-git-send-email-kennetkl@ifi.uio.no>
	<CAK6E8=c1S5kmdZ8mjAf4+5otH8CeVjRD6VyGaS-U1tEMaGLgag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:36498 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbbD3WUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:20:34 -0400
Received: by wgen6 with SMTP id n6so76985666wge.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:20:33 -0700 (PDT)
In-Reply-To: <CAK6E8=c1S5kmdZ8mjAf4+5otH8CeVjRD6VyGaS-U1tEMaGLgag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There might be congestion control that assumes pkts_acked > 0 or data
> is cumulatively when this is called. Did you audit that?

HTCP, Illinois, Yeah:
These modules save the pkts_acked count internally and use it to grow
snd_cwnd_cnt in cong_avoid.
This patch ensures they grow by the same count that is passed to cong_avoid().

BIC:
Works well with pkts_acked = 0.

These modules have pkts_acked functions for RTT, but are not using the
acked count:
Cubic, LP, Vegas, Veno, Westwood.

PS on BIC:
Impossibly high counts can potentially overflow ca->delayed_ack to 0
and cause division by zero, e.g. (u32) -30.
