From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Fix CWV being too strict on thin streams
Date: Tue, 22 Sep 2015 07:46:36 -0700
Message-ID: <1442933196.29850.94.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com>
	 <CADVnQy=BXvWMXUGeeABjsHDpfa4FF+RUfCvJXpupcyYKG+=+ig@mail.gmail.com>
	 <8021096.gY5K1ti0Dn@garfield>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>
To: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34777 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756257AbbIVOqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 10:46:38 -0400
Received: by padhy16 with SMTP id hy16so11341715pad.1
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 07:46:38 -0700 (PDT)
In-Reply-To: <8021096.gY5K1ti0Dn@garfield>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-22 at 16:29 +0200, Bendik R=C3=B8nning Opstad wrote:
> > Thanks for this report!
>=20
> Thank you for answering!
>=20
> > When you say "CWND is reduced due to loss", are you talking about R=
TO
> > or Fast Recovery? Do you have any traces you can share that illustr=
ate
> > this issue?
>=20
> The problem is not related to loss recovery, but only occurs in conge=
stion
> avoidance state. This is because tcp_is_cwnd_limited(), called from t=
he
> congestion controls ".cong_avoid" hook, will only use tp->is_cwnd_lim=
ited when
> in congestion avoidance.
>=20
> I've made two traces to compare the effect with and without the patch=
:
> http://heim.ifi.uio.no/bendiko/traces/CWV_PATCH/
>=20
> To ensure that the results are comparable, the traces are produced wi=
th an extra
> patch applied (shown below) such that both connections are in congest=
ion
> avoidance from the beginning.
>=20
> > Have you verified that this patch fixes the issue you identified? I
> > think the fix may be in the wrong place for that scenario, or at le=
ast
> > incomplete.
>=20
> Yes, we have tested this and verified that the patch solves the issue=
 in the
> test scenarios we've run.
>=20
> As always (in networking) it can be difficult to reproduce the issue =
in a
> consistent manner, so I will describe the setup we have used.
>=20


Ahem.

packetdrill can make this in one script, as you can exactly control the
packets that the 'remote' peer would answer.

No need for complex setup. You should try it, and as a bonus we could
easily reproduce the problem and check the fix.

Let see if we can cook a packetdrill scenario.
