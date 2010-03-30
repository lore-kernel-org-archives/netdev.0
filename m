From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing policy->walk.dead
Date: Tue, 30 Mar 2010 17:01:47 +0300
Message-ID: <4BB2044B.5080704@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-2-git-send-email-timo.teras@iki.fi> <20100329144339.GA26214@gondor.apana.org.au> <4BB1842B.9010704@iki.fi> <20100330115351.GA5731@gondor.apana.org.au> <4BB1E8B1.4030604@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:56608 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab0C3OBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 10:01:50 -0400
Received: by ewy20 with SMTP id 20so1277371ewy.1
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 07:01:48 -0700 (PDT)
In-Reply-To: <4BB1E8B1.4030604@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> On Tue, Mar 30, 2010 at 07:55:07AM +0300, Timo Ter=E4s wrote:
>>> Herbert Xu wrote:
>>>> On Mon, Mar 29, 2010 at 05:12:38PM +0300, Timo Teras wrote:
>>>>> @@ -1132,7 +1119,7 @@ int xfrm_sk_policy_insert(struct sock *sk,=20
>>>>> int dir, struct xfrm_policy *pol)
>>>>>          __xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
>>>>>      }
>>>>>      if (old_pol)
>>>>> -        __xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
>>>>> +        old_pol =3D __xfrm_policy_unlink(old_pol, XFRM_POLICY_MA=
X+dir);
>>>>>      write_unlock_bh(&xfrm_policy_lock);
>>>>>       if (old_pol) {
>>>> So when can this actually fail?
>>> Considering that the socket reference is received from the=20
>>> sk->sk_policy,
>>> and the hash bucket we use is "XFRM_POLICY_MAX+dir", it's non-obvio=
us if
>>> it can fail or not.
>>>
>>> It would look like the timer can kill a policy and unlink it, but i=
t
>>> would still be found from sk_policy.
>>
>> Socket policies cannot expire.
>=20
> Was not aware of that. The above is not needed then.

Since the exported function xfrm_policy_byid() can result in deletion
of socket policy, it's safer to leave this change in. This is can be
even triggered via xfrm_user since it does not check 'dir' for the
policy expired message it handles. Any custom module could do similar
harm.
