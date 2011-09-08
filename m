From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Thu, 08 Sep 2011 15:28:17 +0200
Message-ID: <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
	 <1315372100.3400.76.camel@edumazet-laptop>  <4E66FF38.9000107@intel.com>
	 <1315381503.3400.85.camel@edumazet-laptop>
	 <1315396903.2364.23.camel@schen9-mobl>
	 <1315430766.2532.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59240 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932777Ab1IHN2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 09:28:15 -0400
Received: by wyh22 with SMTP id 22so635936wyh.19
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 06:28:14 -0700 (PDT)
In-Reply-To: <1315430766.2532.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 septembre 2011 =C3=A0 23:26 +0200, Eric Dumazet a =C3=A9=
crit :
> Le mercredi 07 septembre 2011 =C3=A0 05:01 -0700, Tim Chen a =C3=A9cr=
it :

> > Eric, are you planning to do a fast path patch that doesn't do pid =
ref
> > for the case where CONFIG_PID_NS is not set?
> >=20
>=20
> Yes, I'll try to cook a patch.

Thinking a bit more on this issue, I really believe we should not stick
pid/cred in skbs sent from a write() system call.

That would break following use case :

An application uses a write(fd) and expects a receiver using recvmsg()
to get process credentials (SCM_CREDENTIALS)

This is currently working, but not documented (man unix says ancillary
data are sent with sendmsg())

If everybody agrees, I can send a patch for this : This would speedup
write()/read() af_unix by an order of magnitude.
