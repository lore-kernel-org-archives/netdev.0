From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in
 store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 15:53:51 +0100
Message-ID: <1324652031.2223.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
	 <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop>
	 <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com>
	 <1324616007.2674.8.camel@edumazet-laptop>
	 <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com>
	 <1324617390.2674.13.camel@edumazet-laptop>
	 <1324618555.10854.4.camel@edumazet-laptop>
	 <4DA4756B-0654-49F4-B135-9A9F89BC7D21@gmail.com>
	 <1324645592.2223.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <EC59D18E-82F6-4409-BB29-D7434D63B0C9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56813 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab1LWOx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 09:53:57 -0500
Received: by wgbdr13 with SMTP id dr13so17570776wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 06:53:56 -0800 (PST)
In-Reply-To: <EC59D18E-82F6-4409-BB29-D7434D63B0C9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 09:30 -0500, Xi Wang a =C3=A9c=
rit :
> On Dec 23, 2011, at 8:06 AM, Eric Dumazet wrote:
>=20
> > I'll submit following patch for net-next, once your patch is in thi=
s
> > tree.
>=20
> Thanks for doing this. ;-)
>=20
> > 		count =3D roundup_pow_of_two(count);
> > +		if (!count ||
> > +		    count !=3D (unsigned long)(u32)count)
> > +			return -EINVAL;
> > 		if (count > (ULONG_MAX - sizeof(struct rps_dev_flow_table))
> > 				/ sizeof(struct rps_dev_flow)) {
> > 			/* Enforce a limit to prevent overflow */
>=20
> I would rather avoid undefined behavior in C.
>=20

Unsigned arithmetics is well defined in C. Very well in fact.


> Given count =3D ULONG_MAX on 64-bit systems, roundup_pow_of_two()
> would overflow, and the overflowed result is undefined, e.g.,
> on x86-64 it gives 1, not 0.  That's why I used INT_MAX.
>=20

I'll check roundup_pow_of_two(), this seems a bug to me.

Problem is : INT_MAX doesnt allow the full range of rps : 2^32 flows.

> BTW, (count > UINT_MAX) is shorter and more easier to understand
> than (count !=3D (unsigned long)(u32)count).

You miss the point. UINT_MAX is too small for 64bit arches.

if (count !=3D (unsigned long)(u32)count)

is pretty common stuff in kernel.

Check _kstrtoul() for an example.
