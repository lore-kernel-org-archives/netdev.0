From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [TCP] FRTO: Fix fallback to conventional recovery
Date: Tue, 13 May 2008 02:53:50 -0700 (PDT)
Message-ID: <20080513.025350.127189853.davem@davemloft.net>
References: <1210671834-15406-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, damon@damtek.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59754
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752105AbYEMJx4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 05:53:56 -0400
In-Reply-To: <1210671834-15406-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 13 May 2008 12:43:53 +0300

> It seems that commit 009a2e3e4ec ("[TCP] FRTO: Improve
> interoperability with other undo_marker users") run into
> another land-mine which caused fallback to conventional
> recovery to break:
>=20
> 1. Cumulative ACK arrives after FRTO retransmission
> 2. tcp_try_to_open sees zero retrans_out, clears retrans_stamp
>    which should be kept like in CA_Loss state it would be
> 3. undo_marker change allowed tcp_packet_delayed to return
>    true because of the cleared retrans_stamp once FRTO is
>    terminated causing LossUndo to occur, which means all loss
>    markings FRTO made are reverted.
>=20
> This means that the conventional recovery basically recovered
> one loss per RTT, which is not that efficient. It was quite
> unobvious that the undo_marker change broken something like
> this, I had a quite long session to track it down because of
> the non-intuitiviness of the bug (luckily I had a trivial
> reproducer at hand and I was also able to learn to use kprobes
> in the process as well :-)).
>=20
> This together with the NewReno+FRTO fix and FRTO in-order
> workaround this fixes Damon's problems, this and the first
> mentioned are enough to fix Bugzilla #10063.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Reported-by: Damon L. Chesser <damon@damtek.com>
> Tested-by: Damon L. Chesser <damon@damtek.com>
> Tested-by: Sebastian Hyrwall <zibbe@cisko.org>

Applied.
