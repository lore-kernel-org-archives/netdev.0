From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: loopback IP alias breaks tftp?
Date: Mon, 10 Oct 2011 17:22:06 +0200
Message-ID: <1318260126.3227.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111005202723.GE2479@zod.bos.redhat.com>
	 <alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
	 <20111006132353.GF2479@zod.bos.redhat.com>
	 <CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com>
	 <1317972573.3457.55.camel@edumazet-laptop>
	 <20111007114017.GA1165@zod.bos.redhat.com>
	 <1317989073.3207.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1317990201.3207.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111010151058.GD1165@zod.bos.redhat.com>
	 <CAGVGHmsF3JBqpqzKa_Fp6oOcVKX5BKgJUG=UJvPZcNgKiSsrRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Boyer <jwboyer@redhat.com>, Joel Sing <jsing@google.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	francis.souyri@apec.fr
To: Olaf van der Spek <ml@vdspek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33281 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab1JJPVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 11:21:52 -0400
Received: by bkbzt4 with SMTP id zt4so8589451bkb.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 08:21:51 -0700 (PDT)
In-Reply-To: <CAGVGHmsF3JBqpqzKa_Fp6oOcVKX5BKgJUG=UJvPZcNgKiSsrRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 octobre 2011 =C3=A0 17:15 +0200, Olaf van der Spek a =C3=A9=
crit :
> > On Fri, Oct 07, 2011 at 02:23:21PM +0200, Eric Dumazet wrote:
> >> By the way, there is no need for tftp change :
> >>
> >> Just launch several tftpd instances, and bind each them to one
> >> particular IP.
> >>
> >> If started from xinetd.d :
>=20
> Isn't that a bad way to work around this issue?
> It'd require you to duplicate your IP config for every daemon that
> listens on UDP interfaces.
> What about IP addresses that are added/deleted after the daemon is la=
unchad?
>=20
> Olaf

Thats a pretty common problem, even prior to discussed commit.

If you take a look at common UDP daemons, they have to setup a listener
for each IP address, OR use the correct API ( setsockopt(fd, IPPROTO_IP=
,
&on, sizeof(on)) and handle IP_PKTINFO ancillary message)
