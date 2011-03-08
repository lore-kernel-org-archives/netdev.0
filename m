From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH] tcp_cubic: enable TCP timestamps
Date: Tue, 8 Mar 2011 20:36:02 +0100
Message-ID: <20110308193602.GA14526@xanadu.blop.info>
References: <20110308080926.GA22641@xanadu.blop.info>
 <20110308104211.3567526f@nehalam>
 <20110308.105503.104060436.davem@davemloft.net>
 <AANLkTinT0eHbbELWDLxYyj0axpYt=GHnxLP8fMH-pWOs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Sangtae Ha <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:48679 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754669Ab1CHTfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 14:35:12 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTinT0eHbbELWDLxYyj0axpYt=GHnxLP8fMH-pWOs@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/11 at 14:15 -0500, Sangtae Ha wrote:
> Yes. I remember that CONFIG_HZ was 1000 at that time and the value of
> CONFIG_HZ could affect the algorithm.
> I don't think HyStart needs this extra RTT_STAMP since we only need a
> rough delay estimate.
> Let me check HyStart with the latest git and with different CONFIG_HZ=
 values.

One of the problems I discovered was that ca->delay_min was completely
off if RTT_STAMP is disabled. For example, on a link with a 11ms RTT, I
could get delay_min =3D 4ms. But even with RTT_STAMP, there's the probl=
em
that the code rounds the computed RTT value to a jiffie (in
bictcp_acked()).

My other patch mitigates the performance problem by making it harder fo=
r
Hystart to abort slow start. But after a few days working on this issue=
,
I'm wondering whether Hystart shouldn't be completely rewritten to work
on the usec values, or disabled by default.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
