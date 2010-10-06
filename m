From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: Regarding to your linux kernel CL
Date: Wed, 06 Oct 2010 10:02:56 +0300
Message-ID: <4CAC1F20.6070009@iki.fi>
References: <AANLkTikdcL0JQgkR6u0qtmDu-phMZ6-Juq91B1N5GfiY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.hengli.com.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: =?UTF-8?B?IkNodW5nLVlpaCBXYW5nICjnjovltIfmh78pIg==?=
	<cywang@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46016 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756906Ab0JFHDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 03:03:05 -0400
Received: by eyb6 with SMTP id 6so2737023eyb.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 00:03:03 -0700 (PDT)
In-Reply-To: <AANLkTikdcL0JQgkR6u0qtmDu-phMZ6-Juq91B1N5GfiY@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2010 04:23 AM, Chung-Yih Wang (=E7=8E=8B=E5=B4=87=E6=87=BF) wr=
ote:
>     I encountered an issue with your CL
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3Dd11a4dc18bf41719c9f0d7ed494d295dd2973b92.
> The cause is that we use a connected UDP socket for building the
> l2tp/ipsec vpn connection. However, when the ipsec tunnel is built,
> your CL made the sk_dst_check useless(since it always return the
> 'freed' dst_entry and can not reset the dst entry for the socket).
> What is your comment to conquer this issue?
>=20
> Solution 1. We could add a CL to change it to (dst && dst->obsolete &=
&
> (dst->obsolete>0  || dst->ops->check(...)=3D=3DNULL) in sk_dst_check(=
)) ?
>=20
> Solution 2. Revert the change?
>=20
> Any comment?

What's the problem here? sk_dst_check not honoring if dst->obsolete>0 ?
Sounds like the sk_dst_check was buggy in the first place.

Looks like there's still some code around that does not do what the
obsolete field has been used for a long time.
  obsolete =3D  0, dst entry is ok
  obsolete =3D -1, you need to call ops->check for this entry
  obsolete >  0, this entry is invalid

So net/core/sock.c needs fixing. Just if we should change dst_check()
too, I'm not sure.

Should we fix sk_dst_check to use dst_check(), and dst_check() to check
for dst->obsolete>0 ?
