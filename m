From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] [TCP]: Fix lost_retrans loop vs fastpath problems
Date: Thu, 11 Oct 2007 17:35:50 -0700 (PDT)
Message-ID: <20071011.173550.39320216.davem@davemloft.net>
References: <11921028673030-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11921028672853-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11921028671668-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, takano@axe-inc.co.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51175
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753383AbXJLAfs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 20:35:48 -0400
In-Reply-To: <11921028671668-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 11 Oct 2007 14:41:06 +0300

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
> in sacktag marker. Trying a simple work until all rexmitted
> skbs heve been processed approach.
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
> Cc: TAKANO Ryousei <takano@axe-inc.co.jp>
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
