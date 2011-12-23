From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in
 store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 06:16:30 +0100
Message-ID: <1324617390.2674.13.camel@edumazet-laptop>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
	 <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop>
	 <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com>
	 <1324616007.2674.8.camel@edumazet-laptop>
	 <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44884 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718Ab1LWFQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 00:16:35 -0500
Received: by wibhm6 with SMTP id hm6so2937486wib.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 21:16:34 -0800 (PST)
In-Reply-To: <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 00:10 -0500, Xi Wang a =C3=A9c=
rit :
> On Dec 22, 2011, at 11:53 PM, Eric Dumazet wrote:
> > All I wanted to say is that while mixing INT_MAX/ULONG_MAX, you cou=
ld
> > have spotted the other bug in the code :
> >=20
> > unsigned int count;
> >=20
> > count =3D simple_strtoul(buf, &endp, 0);
>=20
> Are you suggesting to change the type of "count" to unsigned long?
> That seems like a separate issue from the bounds checking part.
>=20
> I don't see the possible 32-bit truncation here is a serious issue th=
ough.
> The user could even echo "128abc" into rps_flow_cnt and simple_strtou=
l()
> would be happy to pick 128.
>=20

32 bit truncation _is_ a bound checking problem too.

Really, mixing INT_MAX / ULONG_MAX is ugly, this should had ring a bell
when writing such hard to read code.

You cannot claim to give more range to 64bit platform, yet not spotting
the 32bit truncation issue.

When fixing a bug, its always a good thing to look things around, and
try to check the whole function.
