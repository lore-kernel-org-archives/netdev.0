From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH] {iproute2, xfrm}: Use memcpy to suppress gcc phony buffer
 overflow warning
Date: Tue, 8 Oct 2013 09:22:22 +0800
Message-ID: <52535E4E.2090804@windriver.com>
References: <524411AE.7000404@linux.vnet.ibm.com> <52447DAC.2060701@linux.vnet.ibm.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7361@saturn3.aculab.com> <5246D88F.7090906@linux.vnet.ibm.com> <52478710.702@windriver.com> <52479CA0.4050505@linux.vnet.ibm.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7368@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sohny Thomas <sthomas@linux.vnet.ibm.com>,
	<stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42608 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab3JHBWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 21:22:34 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7368@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back from vacation, sorry for the late reply.

On 2013=E5=B9=B409=E6=9C=8830=E6=97=A5 17:29, David Laight wrote:
>>> This is a false positive warning as the destination pointer "buf"
>>> pointers to
>>> an ZERO length array, which actually will occupy alg.buf mostly.
>>> Fix this by using memcpy.
>>>
>>> struct xfrm_algo {
>>>           char            alg_name[64];
>>>           unsigned int    alg_key_len;    /* in bits */
>>>           char            alg_key[0];
>>> };
>>>
>>> struct {
>>>           union {
>>>                   struct xfrm_algo alg;
>>>                   struct xfrm_algo_aead aead;
>>>                   struct xfrm_algo_auth auth;
>>>           } u;
>>>           char buf[XFRM_ALGO_KEY_BUF_SIZE];
>>> } alg =3D {};
>>>
>>> buf =3D alg.u.alg.alg_key;
>
> That is worse than horrid...
> The tools have every right to complain about any accesses to alg_key[=
].

Only when using strcpy, because a build in checking inserted in this fu=
nction.

>>> ---
>>>    ip/xfrm_state.c |    2 +-
>>>    1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
>>> index 0d98e78..5cc87d3 100644
>>> --- a/ip/xfrm_state.c
>>> +++ b/ip/xfrm_state.c
>>> @@ -159,7 +159,7 @@ static int xfrm_algo_parse(struct xfrm_algo *al=
g,
>>> enum xfrm_attr_type_t type,
>>>                if (len>  max)
>>>                    invarg("\"ALGO-KEY\" makes buffer overflow\n", k=
ey);
>
> I presume there is a return hiding in invarg().

Good guess :)

>>>
>>> -            strncpy(buf, key, len);
>>> +            memcpy(buf, key, len);
>
> Passing the length of the SOURCE to strncpy() is almost always wrong.
> You are still not terminating the copied string.

Don't worry.

The length using here has been increased by 1 at the beginning of the f=
unction,
so the copied string to the destination is terminated well.

> 	David
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
