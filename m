From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Thu, 08 Sep 2011 02:24:48 -0700
Message-ID: <1315473888.2301.21.camel@schen9-mobl>
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
	 <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51744 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753147Ab1IHXYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Sep 2011 19:24:18 -0400
In-Reply-To: <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-09-08 at 15:28 +0200, Eric Dumazet wrote:
> Le mercredi 07 septembre 2011 =C3=A0 23:26 +0200, Eric Dumazet a =C3=A9=
crit :
> > Le mercredi 07 septembre 2011 =C3=A0 05:01 -0700, Tim Chen a =C3=A9=
crit :
>=20
> > > Eric, are you planning to do a fast path patch that doesn't do pi=
d ref
> > > for the case where CONFIG_PID_NS is not set?
> > >=20
> >=20
> > Yes, I'll try to cook a patch.
>=20
> Thinking a bit more on this issue, I really believe we should not sti=
ck
> pid/cred in skbs sent from a write() system call.

I prefer this approach too.

>=20
> That would break following use case :
>=20
> An application uses a write(fd) and expects a receiver using recvmsg(=
)
> to get process credentials (SCM_CREDENTIALS)
>=20
> This is currently working, but not documented (man unix says ancillar=
y
> data are sent with sendmsg())
>=20
> If everybody agrees, I can send a patch for this : This would speedup
> write()/read() af_unix by an order of magnitude.
>=20

Looking forward to the patch.  This should improve the scalability of
af_unix.

Tim
