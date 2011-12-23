From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in
 store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 05:53:27 +0100
Message-ID: <1324616007.2674.8.camel@edumazet-laptop>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
	 <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop>
	 <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35839 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393Ab1LWExc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 23:53:32 -0500
Received: by wibhm6 with SMTP id hm6so2930353wib.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 20:53:31 -0800 (PST)
In-Reply-To: <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 23:44 -0500, Xi Wang a =C3=A9crit=
 :
> On Dec 22, 2011, at 11:10 PM, Eric Dumazet wrote:
> >> -		if (count > 1<<30) {
> >> +		if (count > INT_MAX)
> >> +			return -EINVAL;
> >> +		count =3D roundup_pow_of_two(count);
> >> +		if (count > (ULONG_MAX - sizeof(struct rps_dev_flow_table))
> >=20
> > Oh well, you added a bug here, since count is "unsigned int"
> >=20
> > Why mixing INT_MAX in the previous test and ULONG_MAX here ?
>=20
> The first check (count > INT_MAX) is used to avoid overflowing
> roundup_pow_of_two(count), e.g., when count is 0xffffffff.
>=20
> The second check is to avoid overflowing the size for vmalloc().
> It gives a less restrictive upper bound than using INT_MAX/UINT_MAX
> on 64-bit platform.
>=20
> Why do you think it's a bug there?  I agree using two checks looks
> ugly though.
>=20
> - xi

All I wanted to say is that while mixing INT_MAX/ULONG_MAX, you could
have spotted the other bug in the code :

unsigned int count;

count =3D simple_strtoul(buf, &endp, 0);
