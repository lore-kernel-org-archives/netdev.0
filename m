From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Subject: Re: [PATCH] net: Initialize entire flowi struct
Date: Thu, 1 Sep 2011 09:34:27 -0400
Message-ID: <4E5F89E3.5060903@ll.mit.edu>
References: <1314806703-5275-1-git-send-email-david.ward@ll.mit.edu>
 <alpine.LFD.2.00.1108312321400.1826@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms030402060703080008050608"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:57081 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757420Ab1IAOOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Sep 2011 10:14:14 -0400
In-Reply-To: <alpine.LFD.2.00.1108312321400.1826@ja.ssi.bg>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms030402060703080008050608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Hi Julian,

On 08/31/2011 04:51 PM, Julian Anastasov wrote:
> On Wed, 31 Aug 2011, David Ward wrote
>> The entire flowi struct needs to be initialized by afinfo->decode_sess=
ion,
>> because flow_hash_code operates over the entire struct and may otherwi=
se
>> return different hash values for what is intended to be the same key.
> 	Such change will cause problems for callers that
> use flowi4 in stack. Examples:
>
> ip_route_me_harder
> icmp_route_lookup

Thanks for pointing this out.

> 	Not sure if adding size as parameter to flow_hash_code
> is better approach. May be flow_cache_lookup needs to
> determine size from family that can be used for flow_hash_code,
> flow_key_compare and the memcpy(&fle->key, key, sizeof(*key))
> after fle =3D kmem_cache_alloc(flow_cachep, GFP_ATOMIC).

Makes sense to me.  However should we just replace flow_key_compare with =

memcmp then, since the assumptions about constant size and alignment=20
will no longer apply?  Or should there be a separate flow_key_compare=20
function for each family, and have all of the flowi* structures become=20
__attribute__((__aligned__(BITS_PER_LONG/8))) ?

David

> The question is how to get size by family.
>
>> Signed-off-by: David Ward<david.ward@ll.mit.edu>
>> ---
>>   net/ipv4/xfrm4_policy.c |    2 +-
>>   net/ipv6/xfrm6_policy.c |    2 +-
>>   2 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
>> index fc5368a..afce24d 100644
>> --- a/net/ipv4/xfrm4_policy.c
>> +++ b/net/ipv4/xfrm4_policy.c
>> @@ -114,7 +114,7 @@ _decode_session4(struct sk_buff *skb, struct flowi=
 *fl, int reverse)
>>   	u8 *xprth =3D skb_network_header(skb) + iph->ihl * 4;
>>   	struct flowi4 *fl4 =3D&fl->u.ip4;
>>
>> -	memset(fl4, 0, sizeof(struct flowi4));
>> +	memset(fl, 0, sizeof(struct flowi));
>>   	fl4->flowi4_mark =3D skb->mark;
>>
>>   	if (!ip_is_fragment(iph)) {
>> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
>> index d879f7e..9088d38 100644
>> --- a/net/ipv6/xfrm6_policy.c
>> +++ b/net/ipv6/xfrm6_policy.c
>> @@ -129,7 +129,7 @@ _decode_session6(struct sk_buff *skb, struct flowi=
 *fl, int reverse)
>>   	const unsigned char *nh =3D skb_network_header(skb);
>>   	u8 nexthdr =3D nh[IP6CB(skb)->nhoff];
>>
>> -	memset(fl6, 0, sizeof(struct flowi6));
>> +	memset(fl, 0, sizeof(struct flowi));
>>   	fl6->flowi6_mark =3D skb->mark;
>>
>>   	ipv6_addr_copy(&fl6->daddr, reverse ?&hdr->saddr :&hdr->daddr);
>> --=20
>> 1.7.4.1


--------------ms030402060703080008050608
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
iIkIuIMw+4GHBpj5pMpqYTrtQKMAAAAAAAA=
--------------ms030402060703080008050608--
