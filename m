From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] [TCP]: Reduce sacked_out with reno when purging
 write_queue
Date: Mon, 02 Jul 2007 22:00:09 -0700 (PDT)
Message-ID: <20070702.220009.128111387.davem@davemloft.net>
References: <11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11801685621830-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1180168562524-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34327
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752137AbXGCE7u convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 00:59:50 -0400
In-Reply-To: <1180168562524-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 26 May 2007 11:36:01 +0300

> Previously TCP had a transitional state during which reno
> counted segments that are already below the current window into
> sacked_out, which is now prevented. Re-try now unconditional
> S+L catching (I wonder if we could get that BUG_ON place
> pinpointed more exactly in oops because now inlining makes it
> lose its original context as they always seem to be in
> tcp_ack, #define helps?).
>=20
> Beware, this change is not a trivial one and might have some
> unexpected side-effects under obscure conditions since state
> tracking is to happen much later on and the reno sack counting
> was highly depending on the current state.
>=20
> This approach conservatively calls just remove_sack and leaves
> reset_sack() calls alone. The best solution to the whole problem
> would be to first calculate the new sacked_out fully (this patch
> does not move reno_sack_reset calls from original sites and thus
> does not implement this). However, that would require very
> invasive change to fastretrans_alert (perhaps even slicing it to
> two halves). Alternatively, all callers of tcp_packets_in_flight
> (i.e., users that depend on sacked_out) should be postponed
> until the new sacked_out has been calculated but it isn't any
> simpler alternative.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

So basically the idea behind this patch is to do the update of
the fake RENO sakcs in clean_rtx_queue instead of fixing it up
at the very last moment right before we invoke tcp_try_to_undo_partial(=
).

I like this patch and I can't find any holes in the idea.

But some things have changed in the meantime and this patch
(and probably 9/9 too) don't apply cleanly.  Could you respin
these against current tcp-2.6 so I can apply them?

Thanks.
