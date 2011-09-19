From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] af_unix: dont send SCM_CREDENTIALS by default
Date: Mon, 19 Sep 2011 17:02:04 +0200
Message-ID: <1316444524.2539.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315473888.2301.21.camel@schen9-mobl>
	 <1315544777.5410.19.camel@edumazet-laptop>
	 <20110918.210758.2207266633127640132.davem@davemloft.net>
	 <1316406528.2521.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tim.c.chen@linux.intel.com, zheng.z.yan@intel.com,
	yanzheng@21cn.com, netdev@vger.kernel.org, sfr@canb.auug.org.au,
	jirislaby@gmail.com, sedat.dilek@gmail.com, alex.shi@intel.com,
	Valdis.Kletnieks@vt.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42568 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134Ab1ISPB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 11:01:59 -0400
Received: by eya28 with SMTP id 28so1620972eya.19
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 08:01:58 -0700 (PDT)
In-Reply-To: <1316406528.2521.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 septembre 2011 =C3=A0 06:28 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le dimanche 18 septembre 2011 =C3=A0 21:07 -0400, David Miller a =C3=A9=
crit :
> > Eric, please respin your patches against current net-next, thanks!
>=20
> Sure, here it is :
>=20
> Its a bit different, so I didnt add Tim 'Acked-by'
>=20
> [PATCH net-next] af_unix: dont send SCM_CREDENTIALS by default
>=20
> Since commit 7361c36c5224 (af_unix: Allow credentials to work across
> user and pid namespaces) af_unix performance dropped a lot.
>=20
> This is because we now take a reference on pid and cred in each write=
(),
> and release them in read(), usually done from another process,
> eventually from another cpu. This triggers false sharing.

> This patch includes SCM_CREDENTIALS information in a af_unix message/=
skb
> only if requested by the sender, [man 7 unix for details how to inclu=
de
> ancillary data using sendmsg() system call]
>=20
> Note: This might break buggy applications that expected SCM_CREDENTIA=
L
> from an unaware write() system call.


I appears udevd is such an application.

I am trying testing SOCK_PASSCRED flag and include SCM_CREDENTIALS if
set.
