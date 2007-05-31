From: David Miller <davem@davemloft.net>
Subject: Re: Suspicious fackets_out handling
Date: Thu, 31 May 2007 12:59:29 -0700 (PDT)
Message-ID: <20070531.125929.77054675.davem@davemloft.net>
References: <Pine.LNX.4.64.0704231218440.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50036
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758962AbXEaT7P convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 15:59:15 -0400
In-Reply-To: <Pine.LNX.4.64.0704231218440.28337@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 23 Apr 2007 14:28:21 +0300 (EEST)

> There are IMHO two problems in it. First of all, nothing ensures that=
 the=20
> skb TCP is fragmenting is actually below the forwardmost sack block (=
and=20
> thus is included to the fackets_out)...

Good catch, I agree with your analysis completely.

> What I'm not sure of though, is how to fix this in net-2.6(.22), it
> is due to the fact that there is no pointer/seq which can be used in
> testing for it like in tcp-2.6 which has the highest_sack.

We can add highest_sack to 2.6.22 in order to fix a bug like this,
if necessary.

> Second problem is even more obvious: if adjustment here is being
> done and the sacktag code then uses fastpath at the arrival of the
> next ACK, the sacktag code will use a stale value from
> fastpath_cnt_hint and fails to notice all that math TCP did here
> unless we start clearing fastpath_skb_hint.

Let's try not to clear fastpath_skb_hint here if possible :-)

Is it possible to update fastpath_cnt_hint properly perhaps?
