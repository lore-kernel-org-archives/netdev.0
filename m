From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: Fix handling packets on compound
 pages with skb_linearize
Date: Mon, 01 Dec 2014 15:13:37 +0100
Message-ID: <547C7791.3090206@canonical.com>
References: <1407778343-13622-1-git-send-email-zoltan.kiss@citrix.com>	<547C2CFC.7060908@canonical.com> <547C6EF6.8020604@citrix.com> <547C742E.6060801@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="CfN5ETO1kIBvIu4GSFgCuofkmW9bBCxxT"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Paul Durrant <paul.durrant@citrix.com>,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@linaro.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <547C742E.6060801@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--CfN5ETO1kIBvIu4GSFgCuofkmW9bBCxxT
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 01.12.2014 14:59, Zoltan Kiss wrote:
>=20
>=20
> On 01/12/14 13:36, David Vrabel wrote:
>> On 01/12/14 08:55, Stefan Bader wrote:
>>> On 11.08.2014 19:32, Zoltan Kiss wrote:
>>>> There is a long known problem with the netfront/netback interface: i=
f the guest
>>>> tries to send a packet which constitues more than MAX_SKB_FRAGS + 1 =
ring slots,
>>>> it gets dropped. The reason is that netback maps these slots to a fr=
ag in the
>>>> frags array, which is limited by size. Having so many slots can occu=
r since
>>>> compound pages were introduced, as the ring protocol slice them up i=
nto
>>>> individual (non-compound) page aligned slots. The theoretical worst =
case
>>>> scenario looks like this (note, skbs are limited to 64 Kb here):
>>>> linear buffer: at most PAGE_SIZE - 17 * 2 bytes, overlapping page bo=
undary,
>>>> using 2 slots
>>>> first 15 frags: 1 + PAGE_SIZE + 1 bytes long, first and last bytes a=
re at the
>>>> end and the beginning of a page, therefore they use 3 * 15 =3D 45 sl=
ots
>>>> last 2 frags: 1 + 1 bytes, overlapping page boundary, 2 * 2 =3D 4 sl=
ots
>>>> Although I don't think this 51 slots skb can really happen, we need =
a solution
>>>> which can deal with every scenario. In real life there is only a few=
 slots
>>>> overdue, but usually it causes the TCP stream to be blocked, as the =
retry will
>>>> most likely have the same buffer layout.
>>>> This patch solves this problem by linearizing the packet. This is no=
t the
>>>> fastest way, and it can fail much easier as it tries to allocate a b=
ig linear
>>>> area for the whole packet, but probably easier by an order of magnit=
ude than
>>>> anything else. Probably this code path is not touched very frequentl=
y anyway.
>>>>
>>>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>>>> Cc: Wei Liu <wei.liu2@citrix.com>
>>>> Cc: Ian Campbell <Ian.Campbell@citrix.com>
>>>> Cc: Paul Durrant <paul.durrant@citrix.com>
>>>> Cc: netdev@vger.kernel.org
>>>> Cc: linux-kernel@vger.kernel.org
>>>> Cc: xen-devel@lists.xenproject.org
>>>
>>> This does not seem to be marked explicitly as stable. Has someone alr=
eady asked
>>> David Miller to put it on his stable queue? IMO it qualifies quite we=
ll and the
>>> actual change should be simple to pick/backport.
>>
>> I think it's a candidate, yes.
>>
>> Can you expand on the user visible impact of the bug this patch fixes?=

>> I think it results in certain types of traffic not working (because th=
e
>> domU always generates skb's with the problematic frag layout), but I
>> can't remember the details.
>=20
> Yes, this line in the comment talks about it: "In real life there is on=
ly a few
> slots overdue, but usually it causes the TCP stream to be blocked, as t=
he retry
> will most likely have the same buffer layout."
> Maybe we can add what kind of traffic triggered this so far, AFAIK NFS =
was one
> of them, and Stefan had an another use case. But my memories are blur a=
bout this.

We had some report about some web-app hitting packet losses. I suspect th=
at also
was streaming something. For a easy trigger we found redis-benchmark (par=
t of
the redis keyserver) with a larger (iirc 1kB) payload would trigger the
fragmentation/exceeding pages to happen. Though I think it did not fail b=
ut
showed a performance drop instead (from memory which also suffers from lo=
osing
detail).

-Stefan
>=20
> Zoli



--CfN5ETO1kIBvIu4GSFgCuofkmW9bBCxxT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJUfHeRAAoJEOhnXe7L7s6j6z8P/1+ExBbkBFehdN9vJK8WF8CG
2GpL4Ib5/MxoN3L7J5Lj7jXgPn5zAuK402phk4YbOWrTfhUjQZ3UMrEHc1GRpP5Q
dfaSKwSSDAHSuMv5NCvpPK0CrhvxbODNV7V3qU1n3zSSNoY4dHEB1AChVC3qHkxq
ox/LypqTBNRZbc+HO8gcWWHYRLMDwrKpsXiWQiwuKctbZzgJD/mvZC1O5kVHwmoX
FT8xFh8zoxYdzXbWfULcCHhFbdePldfrPCzH22CNy/clau7TCHlHk85IVt91zrHG
KWB8oBhl6bshjngRklZfbK3i1Vr5JcyI9kPziGDlDWV5BJylEDDVahqu2MIt1nxN
+Zi9S5VIq/aGvdajT6wnVBr19vGHF2aY7nI3N3QFMjXVraX1fMB0VGggCFFwaGgU
g4S9RpchwUXehV/3XUAQHYQqHCUeGVoV4hCkWtDzLN6xPlH8u0ozzfJwhpw6r57e
7rqy8nFPY/tW7IbIb82Qoiedwh1D7XWR0T3IZSeXOsZ0SfWaaA3NRK4hdjWSPGPT
MbkNK7kGjrEK7DVkfI27xmjOqJmVXP4KwClF7qRZsZlWUV4bMdDtWiRAitnoatsT
RTqQBk6fNcwu8NL6xQ8QMVecfRtQ6cFQ4IAvOkbQwapqWbnJkebHfkVmHsx5Blqe
8cPN8fjESBKigfsRbv+6
=st42
-----END PGP SIGNATURE-----

--CfN5ETO1kIBvIu4GSFgCuofkmW9bBCxxT--
