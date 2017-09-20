From: =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Wed, 20 Sep 2017 23:37:24 +0200
Message-ID: <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="MggJBlJBiVc2dgqIW4W4ta7v5GBckpevv"
Cc: Wenyou Yang <wenyou.yang@atmel.com>,
        Dong Aisheng <b29396@freescale.com>
To: Franklin S Cooper Jr <fcooper@ti.com>,
        "Yang, Wenyou" <Wenyou.Yang@Microchip.com>,
        Sekhar Nori <nsekhar@ti.com>, wg@grandegger.com,
        mkl@pengutronix.de, socketcan@hartkopp.net,
        quentin.schulz@free-electrons.com, edumazet@google.com,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MggJBlJBiVc2dgqIW4W4ta7v5GBckpevv
Content-Type: multipart/mixed; boundary="obEpxdLknuvMKRT6JLc2FNTi7p2rSpit2";
 protected-headers="v1"
From: =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>
To: Franklin S Cooper Jr <fcooper@ti.com>,
 "Yang, Wenyou" <Wenyou.Yang@Microchip.com>, Sekhar Nori <nsekhar@ti.com>,
 wg@grandegger.com, mkl@pengutronix.de, socketcan@hartkopp.net,
 quentin.schulz@free-electrons.com, edumazet@google.com,
 linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: Wenyou Yang <wenyou.yang@atmel.com>, Dong Aisheng <b29396@freescale.com>
Message-ID: <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
In-Reply-To: <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>

--obEpxdLknuvMKRT6JLc2FNTi7p2rSpit2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US



On 09/20/2017 10:19 PM, Franklin S Cooper Jr wrote:
> Hi Wenyou,
>
> On 09/17/2017 10:47 PM, Yang, Wenyou wrote:
>>
>> On 2017/9/14 13:06, Sekhar Nori wrote:
>>> On Thursday 14 September 2017 03:28 AM, Franklin S Cooper Jr wrote:
>>>> On 08/18/2017 02:39 PM, Franklin S Cooper Jr wrote:
>>>>> During test transmitting using CAN-FD at high bitrates (4 Mbps) onl=
y
>>>>> resulted in errors. Scoping the signals I noticed that only a singl=
e
>>>>> bit
>>>>> was being transmitted and with a bit more investigation realized th=
e
>>>>> actual
>>>>> MCAN IP would go back to initialization mode automatically.
>>>>>
>>>>> It appears this issue is due to the MCAN needing to use the Transmi=
tter
>>>>> Delay Compensation Mode as defined in the MCAN User's Guide. When t=
his
>>>>> mode is used the User's Guide indicates that the Transmitter Delay
>>>>> Compensation Offset register should be set. The document mentions
>>>>> that this
>>>>> register should be set to (1/dbitrate)/2*(Func Clk Freq).
>>>>>
>>>>> Additional CAN-CIA's "Bit Time Requirements for CAN FD" document
>>>>> indicates
>>>>> that this TDC mode is only needed for data bit rates above 2.5 Mbps=
=2E
>>>>> Therefore, only enable this mode and only set TDCO when the data bi=
t
>>>>> rate
>>>>> is above 2.5 Mbps.
>>>>>
>>>>> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
>>>>> ---
>>>>> I'm pretty surprised that this hasn't been implemented already sinc=
e
>>>>> the primary purpose of CAN-FD is to go beyond 1 Mbps and the MCAN I=
P
>>>>> supports up to 10 Mbps.
>>>>>
>>>>> So it will be nice to get comments from users of this driver to
>>>>> understand
>>>>> if they have been able to use CAN-FD beyond 2.5 Mbps without this
>>>>> patch.
>>>>> If they haven't what did they do to get around it if they needed hi=
gher
>>>>> speeds.
>>>>>
>>>>> Meanwhile I plan on testing this using a more "realistic" CAN bus t=
o
>>>>> insure
>>>>> everything still works at 5 Mbps which is the max speed of my CAN
>>>>> transceiver.
>>>> ping. Anyone has any thoughts on this?
>>> I added Dong who authored the m_can driver and Wenyou who added the o=
nly
>>> in-kernel user of the driver for any help.
>> I tested it on SAMA5D2 Xplained board both with and without this patch=
,=20
>> both work with the 4M bps data bit rate.
> Thank you for testing this out. Its interesting that you have been able=

> to use higher speeds without this patch. What is the CAN transceiver
> being used on the SAMA5D2 Xplained board? I tried looking at the
> schematic but it seems the CAN signals are used on an extension board
> which I can't find the schematic for. Also do you mind sharing your tes=
t
> setup? Were you doing a short point to point test?
>
> Thank You,
> Franklin
Hello Franklin,

your patch definitely makes sense.

I forgot the TDC in my patches because it was not present in the
previous driver versions and because I didn't encounter any
problems when testing it myself.

The error is highly dependent on the hardware (transceiver) setup.
So it is definitely possible that some people don't encounter errors
without your patch.

Could you clarify what you meant with
> Scoping the signals I noticed that only a single bit was being transmit=
ted=20

Do you mean one data bit (high bit rate)=C2=A0 or did the core already fa=
il
in the arbitration phase?

There is also another aspect that can lead to errors:

If the CAN clock 'cclk' is above the frequency of the interface/logic
clock 'hclk', the clock domain crossing of the CAN messages can't
work properly. However, I will throw this topic as an extra e-mail into
the round.

Mario

=C2=A0


--obEpxdLknuvMKRT6JLc2FNTi7p2rSpit2--

--MggJBlJBiVc2dgqIW4W4ta7v5GBckpevv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEwjdBGUhyDYwF3W3ckaOeH7OEy/0FAlnC35kACgkQkaOeH7OE
y/3Glg/8C/+1RQgj8zAiNnJaer6mi0FjanPoARSsnoP2qilve9hykIHrCVpZ8gsE
OcDBA5FnOXBKgE0Ni/7XQmGivUu24ba0bSZTr8nzCEHQ3Hw9cciCWHNDIXt3UXXK
gkXb5kjezuuDcItrXPz0HWDQLgwJGa3cgm7uzDRAOzuoc5xVBIIWc56BPUIzo2lm
uvd5N+Y0hF20V/OYhcxEPUfJTPzSpjbpP0HFottXlvEKXCxDGKBpKz/HpLU3KhrY
WisGxGENWhfE025b/TN8V3LT9ICz6qn7a3E06J9nRWG7pMdhj5z5n8LBLEgmU/L5
KvF9dqM1j1uoVvUZw0zSYrmH3NBMpQ+YbiTCmuCSR+FcgbNcLshxQRvF7hTv8+5i
6OX/aZLLiRwDsRqaz8AeQo+XLao9yeKdWhOSqxLN5rVuoMScCO1+2tlo0nzuVZLY
k1Hz0uOBm7lmhvaz//9rAD+rAivklcbW3dtOyu9JG876tfEV0ZeDuUJNDn3yxfh8
hWODDydEHdgSfa7d2qpV5FsW+opdgAh5rkLWe0+BaoTEHK7GYuuKdDXEn5e8OWjk
BC8piykV+duzrFPK3FdQIc0IdKBOFb4FtgNBQe8WL6NelYIsDT+NrKy0xfCuyUA7
f7UH2H4S6FjORkhKEfVGNRLdpv6akB8YQ+Z/A3EwHcdoDnOtxTQ=
=bjyx
-----END PGP SIGNATURE-----

--MggJBlJBiVc2dgqIW4W4ta7v5GBckpevv--
