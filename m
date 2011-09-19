From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Mon, 19 Sep 2011 09:57:31 +0200
Message-ID: <1316419052.2539.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAnqLyK6JWPW_Y8wD=ykqWMn4fPdJ3_7yUUB+TQZWfDJzQ@mail.gmail.com>
	 <1315364126.3400.64.camel@edumazet-laptop>
	 <20110916.193529.1252147879675316417.davem@davemloft.net>
	 <1316191845.2201.5.camel@schen9-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, zheng.z.yan@linux.intel.com,
	zheng.z.yan@intel.com, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, jirislaby@gmail.com, sedat.dilek@gmail.com,
	alex.shi@intel.com
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46912 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977Ab1ISH5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 03:57:24 -0400
Received: by bkbzt4 with SMTP id zt4so5089550bkb.19
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 00:57:23 -0700 (PDT)
In-Reply-To: <1316191845.2201.5.camel@schen9-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 septembre 2011 =C3=A0 09:50 -0700, Tim Chen a =C3=A9crit=
 :
> On Fri, 2011-09-16 at 19:35 -0400, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 07 Sep 2011 04:55:26 +0200
> >=20
> > > Please David just revert 0856a304091b33a8e
> >=20
> > Done.
>=20
> Eric,
>=20
> Can you re-spin a patch that incorporates your idea that we don't
> add pid/credential references when we are not requesting credentials
> in the socket. And probably another one that remove unnecessary
> pid/credentials references in send/receive when we do use credentials=
?

Sure, I did it this morning, please review it if you have some time.

If we find a regression (some popular app doing write() and expecting
credential to be sent to receiver), we could test the SOCK_PASSCRED fla=
g
on receiver socket.
