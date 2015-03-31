From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single
 CAN frame for overlapping CAN filters
Date: Tue, 31 Mar 2015 14:32:16 +0200
Message-ID: <551A93D0.6000302@pengutronix.de>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net> <5519210E.40005@pengutronix.de> <55192872.7000108@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="27fevRjCCcVs0VctxXeT1CoBkdpdidli4"
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <55192872.7000108@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--27fevRjCCcVs0VctxXeT1CoBkdpdidli4
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/30/2015 12:41 PM, Oliver Hartkopp wrote:
> On 30.03.2015 12:10, Marc Kleine-Budde wrote:
>=20
>>>
>>> +	/* eliminate multiple filter matches for the same skb */
>>> +	if (*this_cpu_ptr(ro->uniq_skb) =3D=3D oskb &&
>>> +	    ktime_equal(*this_cpu_ptr(ro->uniq_tstamp), oskb->tstamp)) {
>>> +			return;
>>> +	} else {
>>> +		*this_cpu_ptr(ro->uniq_skb) =3D oskb;
>>> +		*this_cpu_ptr(ro->uniq_tstamp) =3D oskb->tstamp;
>>> +	}
>>> +
>>
>> What happens if you're preempted somewhere in this code, it's not
>> atomic? I think, if we only have to take care about the skb, an atomic=

>> compare exchange would work. But we have two variables....If you use a=

>> struct (see previous mail), I think the usage of get_cpu_ptr(),
>> git_cpu_ptr() ensures that we're not preempted.
>>
>=20
> Please check out
>=20
> https://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/
>=20
> And especially=20
> https://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/x17=
3.html#LOCK-SOFTIRQS-SAME
>=20
> When a softirq processes an incoming skb this remains on that selected =
CPU.

Okay, I was not sure about this. What about preempt_rt?

> The mutithread-test from Andre just lead to the problem that the (forme=
r=20
> single instance) variables ro->uniq_skb and ro->uniq_tstamp have been u=
sed by=20
> different CPUs which made the checks unreliable.

> So following the documentation and other examples in kernel source you =
can
>=20
> - use spinlocks in can_receive() in af_can.c (instead of rcu_read_lock(=
))
> - use per-CPU variables to allow the softirq to run in parallel
>=20
> Just make the variables atomic (as you suggested) is as bad as introduc=
e=20
> spinlocks in can_receive() as you reduce the skb processing to just one=
=20
> thread. So at least percpu is the best for performance but needs to cre=
ate a=20
> vector of variables (percpu).

Ack, lockless atomic-compare-exchange is only possbile for a single
variable.

> Putting a struct into these percpu handling can be done - but does it i=
ncrease=20
> the readability in this case?

It saves ressources, 1 pointer instead of 3 (considering both of your
patches) and only 1 allocation.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--27fevRjCCcVs0VctxXeT1CoBkdpdidli4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVGpPTAAoJECte4hHFiupUwdMP/iC9pwLAYK1TZrb4W+TSYAl/
ExIHeP1jPqfGkdVBcr0JJq5F92D+JWcwtR+sJHmc8weLDOf/OKDfwkczjBBNPgPM
8qk7LDkcn1vukeZShMLIuJzc5iqXVnLCUaSvB2A0jSWlGIvt4NhcJ9cq5BU7P5xC
cHZJDs+RMxpaBt8D0LaHMMtdYKeLQhHHibVqutXTw+n+HFUMONuGT3m3QlB7gS1r
7bAuezZvQuFD/LoExLtyuLZ/WxGJ4EfDGABmR83sdnTRPiHmT1eKzinwfqKic/DX
Gvu0mF3jsnxCIpVCBMIqqnU4Bkvh2v6Q5c7nl3PJyEEVPfIcfDF2sMxzc9SQx3uJ
WaalnUNm4CHOeRZO7beLxMw19qNbflH+OLDOrk7b3RzpAIFwTSoPEbquPxlu4XNn
xunauBYFYm4aNiylILSIps6LR1t5ypCVGws/oq3R7v1Z+cogDgKh3NTPn+Yrv/CX
uVYUn0QQlMi/wLd6ljc22TJRw+4CyElmQ7/E/2Lz4jtj3S9H1269SlSBoRS+aXMI
DiDVtOOkqLhms5XvU/P30ScaXMCyI+n0RNltNNOc0rnoEdIs9/Sh1f/m/xQCfLQm
5Jn62nmllbEBZWKxlpbDdk4+SA4CrVYdpT2CSSPIvsP0mOvI4SeWkVMTqp+Vmzu/
4EGHuOnP0QaGvbtVQ1Xv
=BVWG
-----END PGP SIGNATURE-----

--27fevRjCCcVs0VctxXeT1CoBkdpdidli4--
