From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [PATCH net-next v5] cadence: Add LSO support.
Date: Mon, 14 Nov 2016 09:32:34 +0000
Message-ID: <BN3PR07MB2516C30913D2FB8D4788071AC9BC0@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller [mailto:davem@davemloft.net]=20
Sent: 10 listopada 2016 18:01
To: Rafal Ozieblo
Cc: nicolas.ferre@atmel.com; netdev@vger.kernel.org; linux-kernel@vger.kern=
el.org
Subject: Re: [PATCH net-next v5]] cadence: Add LSO support.

From: Rafal Ozieblo <rafalo@cadence.com>
Date: Wed, 9 Nov 2016 13:41:02 +0000

> First, please remove the spurious closing bracket in your Subject line in=
 future submittions.
>
>> +	if (is_udp) /* is_udp is only set when (is_lso) is checked */
>> +		/* zero UDP checksum, not calculated by h/w for UFO */
>> +		udp_hdr(skb)->check =3D 0;
>
> This is really not ok.
>=20
> If UFO is in use it should not silently disable UDP checksums.
>=20
> If you cannot support UFO with proper checksumming, then you cannot enabl=
e support for that feature.

According Cadence Gigabit Ethernet MAC documentation:

"Hardware will not calculate the UDP checksum or modify the UDP checksum fi=
eld. Therefore software
must set a value of zero in the checksum field in the UDP header (in the fi=
rst payload buffer)
to indicate to the receiver that the UDP datagram does not include a checks=
um."

It is hardware requirement.
