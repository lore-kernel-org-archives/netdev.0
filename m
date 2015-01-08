From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Thu, 08 Jan 2015 07:07:36 -0800
Message-ID: <1420729656.5947.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: =?ISO-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:51323 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbbAHPHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:07:39 -0500
Received: by mail-ie0-f178.google.com with SMTP id vy18so9830188iec.9
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 07:07:38 -0800 (PST)
In-Reply-To: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-08 at 13:20 +0100, S=C3=A9bastien Barr=C3=A9 wrote:
> When the peer has delayed ack enabled, it may reply to a probe with a=
n
> ACK+D-SACK, with ack value set to tlp_high_seq.


The most probable cause would not be a delayed ack (rto should be much
bigger), but a lost ACK.


>  In the current code,
> such ACK+DSACK will be missed and only at next, higher ack will the T=
LP
> episode be considered done. Since the DSACK is not present anymore,
> this will cost a cwnd reduction.
>=20
> This patch ensures that this scenario does not cause a cwnd reduction=
, since
> receiving an ACK+DSACK indicates that both the initial segment and th=
e probe
> have been received by the peer.

Do you have at hand a packetdrill test to demonstrate that the patch
works ?

Thanks !
