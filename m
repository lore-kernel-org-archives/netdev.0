From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bind()/inet_csk_get_port() fails when no port is requested
Date: Wed, 18 Jan 2012 18:50:16 +0100
Message-ID: <1326909016.4910.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120118151126.01a74dc5@asterix.rh>
	 <1326908219.4910.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Marcelo Leitner <mleitner@redhat.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:61406 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932322Ab2ARRuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 12:50:20 -0500
Received: by werb13 with SMTP id b13so573753wer.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 09:50:18 -0800 (PST)
In-Reply-To: <1326908219.4910.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 18:36 +0100, Eric Dumazet a =C3=A9cr=
it :

> Only drawback is when table is really full, we'll scan it twice.
>=20

We should at least add a local_bh_enable() and cond_resched() and jump
to beginning of inet_csk_get_port() to allow pending softirqs/rescheds
to be handled at half way.

	if (!check_conflict) {
		check_conflict =3D true;
		local_bh_enable();
		cond_resched();
		goto start;
	}
