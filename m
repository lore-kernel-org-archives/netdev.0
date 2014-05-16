From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Fri, 16 May 2014 12:17:48 +0200
Message-ID: <5375E5CC.2080904@canonical.com>
References: <537262AB.5010408@canonical.com>	<5373C8D4.2010803@citrix.com>	<1400143605.1006.1.camel@kazak.uk.xensource.com>	<20140515110410.GD1117@zion.uk.xensource.com>	<5374AF88.2070608@canonical.com>	<20140516094842.GA18551@zion.uk.xensource.com> <5375E3EE.6010306@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Dv5gRElc0CADtmLUa9wlWRWOtXtS2F2ix"
Cc: xen-devel@lists.xenproject.org,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	netdev <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:44866 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756802AbaEPKRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 06:17:51 -0400
In-Reply-To: <5375E3EE.6010306@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Dv5gRElc0CADtmLUa9wlWRWOtXtS2F2ix
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 16.05.2014 12:09, Stefan Bader wrote:
> On 16.05.2014 11:48, Wei Liu wrote:
>> On Thu, May 15, 2014 at 02:14:00PM +0200, Stefan Bader wrote:
>> [...]
>>>> Wei.
>>>>
>>> Reading more of the code I would agree. The definition of MAX_SKB_FRA=
GS (at
>>> least now with compound pages) cannot be used in any way to derive th=
e number of
>>> 4k slots a transfer will require.
>>>
>>> Zoltan already commented on worst cases. Not sure it would get as bad=
 as that or
>>> "just" 16*4k frags all in the middle of compound pages. That would th=
en end in
>>> around 33 or 34 slots, depending on the header.
>>>
>>> Zoltan wrote:
>>>> I think the worst case scenario is when every frag and the linear bu=
ffer contains 2 bytes,
>>>> which are overlapping a page boundary (that's (17+1)*2=3D36 so far),=
 plus 15 of
>>> them have a 4k
>>>> page in the middle of them, so, a 1+4096+1 byte buffer can span over=
 3 page.
>>>> That's 51 individual pages.
>>>
>>> I cannot claim to really know what to expect worst case. Somewhat I w=
as thinking
>>> of a
>>> worst case of (16+1)*2, which would be inconvenient enough.
>>>
>>> So without knowing exactly how to do it, but as Ian said it sounds be=
st to come
>>> up with some sort of exception coalescing in cases the slot count goe=
s over 18
>>> and we know the data size is below 64K.
>>>
>>
>> I took a stab at it this morning and came up with this patch. Ran
>> redis-benchmark, it seemed to fix that for me -- only saw one "failed =
to
>> linearize skb" during
>>
>>   redis-benchmark -h XXX -d 1000 -t lrange
>>
>> And before this change, a lot of "rides rocket" were triggered.
>>
>> Thought?
>=20
> It appears at least to me as something that nicely makes use of existin=
g code. I
> was wondering about what could or could not be used. Trying to get ones=
 head
> around the whole thing is kind of a lot to look at.
>=20
> The change at least looks straight forward enough.

The only woe for me is that I am looking puzzled at the implementation of=

skb_linearize(). Somehow the data_len element decides whether a skb can b=
e
linearized and basically how much it tries to pull from the tail. It prob=
ably
makes sense ... just not to me with not deep experience here.

-Stefan


--Dv5gRElc0CADtmLUa9wlWRWOtXtS2F2ix
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJTdeXNAAoJEOhnXe7L7s6j/5MP/0tzgkleYvN21BPcfxz+5UmB
9vf/A1ZBggjR016SFwaoaVKYCO1Z7xHs0OfxUphlhBdskXsfQmtcVh9fi41S8UdA
fYff9vb3xnU02Xklo/8kL2ymhvdMIVBsSAhTvi7shT1xquQTOIaRNwkbY/rGQuc8
lrObrv32CrWnhDAznDegZMeG1KXeFEb+71c3+Ejg+N3GIYpnbXPrt+RCslU7jBdH
1immO4NnOY2YB+H5PCdCkITFims+l3P5KQDKPaoblhG/3wCYJwDI0J4YXEx2qjZz
U/Yg/zqDvPNpp1NJqrIMWIC0rkxiA0Bv5m83x1YjdrJPFw0yR3pv7+nhHdz8dGHe
rbi5n89zKzEDdUBn+Y654ffMAzezHUqgqj2kpEI+AixdcjFOOS1niuy5nVKhd4kf
V6cx0Ga1hCbnMw8U7Ehur1B8SHw3ff8WwA5dF4z6JC2ovyjG4YhUeeyC+GmKUPE8
/MeXeYHspF22MMNKfSjTj7EWwzKjHJOmGy3xsVVlx8hUpYs3qhxaWuks8vj4MFWB
SjEUVXov+bFFZTv5wYYI5uiG2wzziJ5+WGLoIZ8sP9hMmxnjger+rYCkeLgNm57K
0m4e/Kv9tbJH0vvu7E7jqszrAHTuV/qlPrcigto//HxjfxBKcWepk6gKGGNfd07m
CPrBaPusxIa9G/CLqlGP
=q312
-----END PGP SIGNATURE-----

--Dv5gRElc0CADtmLUa9wlWRWOtXtS2F2ix--
