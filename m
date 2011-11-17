From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] net, bridge: print log message after state changed
Date: Thu, 17 Nov 2011 20:23:53 +0100
Message-ID: <20111117192353.GD2051622@jupiter.n2.diac24.net>
References: <1320941934-3534-1-git-send-email-holger.brunck@keymile.com>
 <20111114.003702.1097206603722725705.davem@davemloft.net>
 <1321254211.4072.29.camel@pc005091.de.keymile.net>
 <20111114.020749.1176229013272872343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang.Fritz@keymile.com, holger.brunck@keymile.com,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:46555 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754788Ab1KQTXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 14:23:50 -0500
Content-Disposition: inline
In-Reply-To: <20111114.020749.1176229013272872343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 02:07:49AM -0500, David Miller wrote:
> >> The message is therefore appropriately timed as far as I'm concerned.
> >> 
> > 
> > It's not.
> > 
> > Please test: create a bridge with STP disabled, add an interface to the
> > bridge and set that interface down. You get the message "... entering
> > forwarding state". That's wrong because it's "about to enter" disabled
> > state some lines later.
> > 
> > All other (4) calls to br_log_state are located after the state change,
> > see for example br_stp_enable_port() just some lines above the patch.
> 
> I would never expect an "entering" message to print out after the event
> happens, and in fact I'd _always_ want to see it beforehand so that if
> the state change caused a crash or similar it'd be that much easier
> to pinpoint the proper location.

There seems to be a misunderstanding here. The patch effectively does:
-       br_log_state(p);
        p->state = BR_STATE_DISABLED;
+       br_log_state(p);

and the issue it is trying to fix is not the timing but rather the code
printing the wrong (old, now-left) state.

I do agree that the log message should be printed before anything
happens, so, Holger, can you brew a patch that does that?


-David
