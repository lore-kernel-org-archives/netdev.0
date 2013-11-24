From: Fan Du <fan.du@windriver.com>
Subject: Re: Possible bit/byte conversion mistake in xfrm_state.c
Date: Sun, 24 Nov 2013 19:54:55 +0800
Message-ID: <5291E90F.2060902@windriver.com>
References: <528F7009.4080303@joanneum.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "Marksteiner, Stefan" <stefan.marksteiner@joanneum.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50466 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005Ab3KXLwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 06:52:17 -0500
In-Reply-To: <528F7009.4080303@joanneum.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please wrap the line in shorter length ;)

On 2013=E5=B9=B411=E6=9C=8822=E6=97=A5 22:54, Marksteiner, Stefan wrote=
:
> Hi folks,
>
> I might have found a little bit/byte mistake in xfrm_state.c of iprou=
te2-3.11.0 (and also lower versions).
>
> In line 169 the algorithm length is set correctly ("alg->alg_key_len =
=3D len * 8;") in bits (as it is supposed by /usr/include/linux/xfrm.h,=
 line 101), but later in line 496 the same value is read and added to a=
 length value in bytes ("len +=3D alg.u.alg.alg_key_len;").
>
> I'm not completetly sure, but I'm wondering if this might lead to err=
ors for algorithms with big key sizes (>2048 bits) for the key buffer (=
"char buf[RTA_BUF_SIZE]" in line 274) reserves only 2048 bytes of memor=
y (RTA_BUF_SIZE=3D2048). So taking bits for bytes, the following memcop=
y operation may overwrite adjacent memory areas.
>
> Can somebody verify if this is in fact an issue? Maybe I'm reading th=
is whole stuff wrong.

You are totally right about this bit/byte mistake here.

Normally the aes key len is 128bits, and 160bits for sha1, and
the key buf  defined here is XFRM_ALGO_KEY_BUF_SIZE 512 bytes,
so there are stale data append after each key content, although
is not used by key interface anyway, which means the IPsec
communication goes well after all.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan fan
