From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Tue, 30 Mar 2010 19:53:51 +0800
Message-ID: <20100330115351.GA5731@gondor.apana.org.au>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-2-git-send-email-timo.teras@iki.fi> <20100329144339.GA26214@gondor.apana.org.au> <4BB1842B.9010704@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:39898 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754513Ab0C3Lxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 07:53:55 -0400
Content-Disposition: inline
In-Reply-To: <4BB1842B.9010704@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 07:55:07AM +0300, Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> On Mon, Mar 29, 2010 at 05:12:38PM +0300, Timo Teras wrote:
>>> @@ -1132,7 +1119,7 @@ int xfrm_sk_policy_insert(struct sock *sk, in=
t dir, struct xfrm_policy *pol)
>>>  		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
>>>  	}
>>>  	if (old_pol)
>>> -		__xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
>>> +		old_pol =3D __xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
>>>  	write_unlock_bh(&xfrm_policy_lock);
>>>   	if (old_pol) {
>>
>> So when can this actually fail?
>
> Considering that the socket reference is received from the sk->sk_pol=
icy,
> and the hash bucket we use is "XFRM_POLICY_MAX+dir", it's non-obvious=
 if
> it can fail or not.
>
> It would look like the timer can kill a policy and unlink it, but it
> would still be found from sk_policy.

Socket policies cannot expire.

In fact, they probably shouldn't even be on the bydst or any other
hash table.  I think the only reason they're there at all is because
the hash table was added to __xfrm_policy_link which happens to be
used by socket policies.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
