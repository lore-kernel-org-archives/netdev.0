From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: ipv6: Do not depend on rt->n in rt6_probe().
Date: Tue, 22 Jan 2013 03:41:10 +0900
Message-ID: <50FD8BC6.1030509@linux-ipv6.org>
References: <20130121182858.GA8808@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kbuild@01.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50500 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751134Ab3AUSlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 13:41:12 -0500
In-Reply-To: <20130121182858.GA8808@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2013=E5=B9=B401=E6=9C=8822=E6=97=A5 03:28), Dan Carpenter wrote:
> Hello YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E,
>=20
> This is a semi-automatic email about new static checker warnings.
>=20
> The patch 2152caea7196: "ipv6: Do not depend on rt->n in=20
> rt6_probe()." from Jan 17, 2013, leads to the following Smatch=20
> complaint:
>=20
> net/ipv6/route.c:495 rt6_probe()
> 	 error: we previously assumed 'neigh' could be null (see line 490)
>=20
> net/ipv6/route.c
>    489=09
>    490		if (!neigh ||
>                      ^^^^^
> New test.
>=20
>    491		    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.r=
tr_probe_interval)) {
>    492			struct in6_addr mcaddr;
>    493			struct in6_addr *target;
>    494=09
>    495			neigh->updated =3D jiffies;
>                         ^^^^^^^^^^^^^^
> Old dereference.
>=20
>    496=09
>    497			if (neigh)
>                             ^^^^^
> Another new test.

Oh, right, I'll fix.  Thanks!

--yoshfuji
