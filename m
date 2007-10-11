From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: [RFC PATCH] [TCP]: Fix lost_retrans loop vs fastpath problems
Date: Thu, 11 Oct 2007 10:55:26 +0900 (JST)
Message-ID: <20071011.105526.17823985.takano@axe-inc.co.jp>
References: <11919324023597-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11919324023846-git-send-email-ilpo.jarvinen@helsinki.fi>
	<119193240269-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:55575 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755108AbXJKBzf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 21:55:35 -0400
In-Reply-To: <119193240269-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH] [TCP]: Fix lost_retrans loop vs fastpath problems
Date: Tue,  9 Oct 2007 15:20:01 +0300

> Detection implemented with lost_retrans must work also when
> fastpath is taken, yet most of the queue is skipped including
> (very likely) those retransmitted skb's we're interested in.
> This problem appeared when the hints got added, which removed
> a need to always walk over the whole write queue head.
> Therefore decicion for the lost_retrans worker loop entry must
> be separated from the sacktag processing more than it was
> necessary before.
>=20
> It turns out to be problematic to optimize the worker loop
> very heavily because ack_seqs of skb may have a number of
> discontinuity points. Maybe similar approach as currently is
> implemented could be attempted but that's becoming more and
> more complex because the trend is towards less skb walking
> in sacktag marker.
>=20
> Maybe after(highest_sack_end_seq, tp->high_seq) checking is not
> sufficiently accurate and causes entry too often in no-work-to-do
> cases. Since that's not known, I've separated solution to that
> from this patch.
>=20
> Noticed because of report against a related problem from TAKANO
> Ryousei <takano@axe-inc.co.jp>. He also provided a patch to
> that part of the problem. This patch includes solution to it
> (though this patch has to use somewhat different placement).
> TAKANO's description and patch is available here:
>=20
>   http://marc.info/?l=3Dlinux-netdev&m=3D119149311913288&w=3D2
>=20
> ...In short, TAKANO's problem is that end_seq the loop is using
> not necessarily the largest SACK block's end_seq because the
> current ACK may still have higher SACK blocks which are later
> by the loop.
>=20
Thanks Ilpo!  I am trying to evaluate this patch. But, I got=20
a kernel panic at net_rx_action() in our experimental setting.
I am using the net-2.6.24 kernel _without_ this patch.=20
(I will post a bug report separately).
Anyway, I will report the result as soon as possible.

Ryousei Takano
