From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/4] cxgb4: Use mask & shift while returning vlan_prio
Date: Wed, 16 Dec 2015 17:40:41 -0800
Message-ID: <B7C06B31-B31A-453D-AA4E-4C836056832E@chelsio.com>
References: <1450251988-9246-1-git-send-email-hariprasad@chelsio.com> <1450251988-9246-2-git-send-email-hariprasad@chelsio.com> <20151216.190733.272791166074460566.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	nirranjan@chelsio.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:8187 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751356AbbLQBtt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 20:49:49 -0500
In-Reply-To: <20151216.190733.272791166074460566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Dec 16, 2015, at 4:07 PM, David Miller <davem@davemloft.net> wrote=
:
>=20
> From: Hariprasad Shenai <hariprasad@chelsio.com>
> Date: Wed, 16 Dec 2015 13:16:25 +0530
>=20
>> @@ -66,7 +66,7 @@ struct l2t_data {
>>=20
>> static inline unsigned int vlan_prio(const struct l2t_entry *e)
>> {
>> -	return e->vlan >> 13;
>> +	return (e->vlan & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
>=20
> e->vlan is a u16, the vlan priotity is the top 3 bits of the 16-bit
> value, and finally the right shift will be non-signed.
>=20
> Therefore this change is absolutely not necessary.
>=20
> Please remove this patch from the series and resend.

I assume that you only meant that the masking portion is unnecessary.  =
Doing the shift with the symbolic constant VLAN_PRIO_SHIFT instead of t=
he literal constant =E2=80=9C13=E2=80=9D is still a reasonable change. =
 The masking was almost certainly from me because once one uses the sym=
bolic constants, weren=E2=80=99t not supposed to =E2=80=9Cknow=E2=80=9D=
 about the internal structure of the operation.  Modern compilers are o=
f course free to optimize away the mask, etc.

Casey