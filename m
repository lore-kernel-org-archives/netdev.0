From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] [TCP]: FRTO undo response falls back to ratehalving
 one if ECEd
Date: Fri, 02 Mar 2007 13:34:01 -0800 (PST)
Message-ID: <20070302.133401.107943210.davem@davemloft.net>
References: <Pine.LNX.4.64.0703021329520.19465@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0703021430570.3770@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44343
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030177AbXCBVeD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 16:34:03 -0500
In-Reply-To: <Pine.LNX.4.64.0703021430570.3770@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 2 Mar 2007 14:34:36 +0200 (EET)

> Undoing ssthresh is disabled in fastretrans_alert whenever
> FLAG_ECE is set by clearing prior_ssthresh. The clearing does
> not protect FRTO because FRTO operates before fastretrans_alert.
> Moving the clearing of prior_ssthresh earlier seems to be a
> suboptimal solution to the FRTO case because then FLAG_ECE will
> cause a second ssthresh reduction in try_to_open (the first
> occurred when FRTO was entered). So instead, FRTO falls back
> immediately to the rate halving response, which switches TCP to
> CA_CWR state preventing the latter reduction of ssthresh.
>=20
> If the first ECE arrived before the ACK after which FRTO is able
> to decide RTO as spurious, prior_ssthresh is already cleared.
> Thus no undoing for ssthresh occurs. Besides, FLAG_ECE should be
> set also in the following ACKs resulting in rate halving response
> that sees TCP is already in CA_CWR, which again prevents an extra
> ssthresh reduction on that round-trip.
>=20
> If the first ECE arrived before RTO, ssthresh has already been
> adapted and prior_ssthresh remains cleared on entry because TCP
> is in CA_CWR (the same applies also to a case where FRTO is
> entered more than once and ECE comes in the middle).
>=20
> High_seq must not be touched after tcp_enter_cwr because CWR
> round-trip calculation depends on it.
>=20
> I believe that after this patch, FRTO should be ECN-safe and
> even able to take advantage of synergy benefits.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, but I had to apply this by hand, you did not generate
this diff against tcp-2.6

And I'm very angry about this specific case because I told you
EXPLICITLY that I reformated the switch() statement when I applied
the earlier FRTO patches.

Not only are people expected to patch against tcp-2.6, BUT I TOLD
YOU specifically that I modified your patch in this specific area.

What else do I need to do in order for people to generate clean
patches? :-(  Tell me, I'll do it!!!

