From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] [TCP]: Bidir flow must not disregard SACK
 blocks for lost marking
Date: Mon, 30 Jul 2007 19:53:46 -0700 (PDT)
Message-ID: <20070730.195346.124870288.davem@davemloft.net>
References: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0707302019110.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40534
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934642AbXGaCxy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 22:53:54 -0400
In-Reply-To: <Pine.LNX.4.64.0707302019110.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 30 Jul 2007 20:19:40 +0300 (EEST)

> It's possible that new SACK blocks that should trigger new LOST
> markings arrive with new data (which previously made is_dupack
> false). In addition, I think this fixes a case where we get
> a cumulative ACK with enough SACK blocks to trigger the fast
> recovery (is_dupack would be false there too).
>=20
> I'm not completely pleased with this solution because readability
> of the code is somewhat questionable as 'is_dupack' in SACK case
> is no longer about dupacks only but would mean something like
> 'lost_marker_work_todo' too... But because of Eifel stuff done
> in CA_Recovery, the FLAG_DATA_SACKED check cannot be placed to
> the if statement which seems attractive solution. Nevertheless,
> I didn't like adding another variable just for that either... :-)
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I've applied this as well.

I don't mind the complex conditionals so much in loss
handling, they are almost inevitable.  However I believe
they could be simplified as a lot of pieces of code ask
similar if not identical questions.

We could ask several of these things up-front, regardless
of path we will take (reno, DSACK, reorder, FRTO, etc.)
and pass the answers along in a bitmask.  We do that to
some extent already with how we analyze the retransmit
queue at the beginning of ACK processing.


