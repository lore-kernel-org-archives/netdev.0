From: "Yalagandula, Praveen" <praveen.yalagandula@hp.com>
Subject: bug in qavg calculation in include/net/red.h (resending as
 plain-text email)
Date: Thu, 5 Jan 2012 19:30:56 +0000
Message-ID: <67E2BF19E6D6A749A7680AEF496EB37C39D9204067@GVW0547EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yalagandula, Praveen" <praveen.yalagandula@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:35751 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538Ab2AETcF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:32:05 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Resending as plain text)

Dear Alexey,

The code (see below) for computing the queue average for RED implementa=
tion in Linux kernel has a bug. The return line should be "return p->qa=
vg + ((backlog - p->qavg) >> p->Wlog);".=20

qavg =3D qavg*(1-W) + backlog*W

=A0=A0=A0=A0 =3D qavg + (backlog-qavg)*W

The current buggy code applies right shift to only the previous qavg, w=
here as it should be applied to (backlog - qavg). Hope you can get this=
 bug corrected.

Thanks,
Praveen Yalagandula
Senior Researcher, HP Labs, Palo Alto, CA

-------------------------------------

static inline unsigned long red_calc_qavg_no_idle_time(struct red_parms=
 *p, unsigned int backlog)
{
=A0=A0=A0=A0 /*
=A0=A0=A0=A0 * NOTE: p->qavg is fixed point number with point at Wlog.
=A0=A0=A0=A0 * The formula below is equvalent to floating point
=A0=A0=A0=A0 * version:
=A0=A0=A0=A0 *
=A0=A0=A0=A0 * =A0 qavg =3D qavg*(1-W) + backlog*W;
=A0=A0=A0=A0 *
=A0=A0=A0=A0 * --ANK (980924)
=A0=A0=A0=A0 */
=A0=A0=A0=A0 return p->qavg + (backlog - (p->qavg >> p->Wlog));
}
