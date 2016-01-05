From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH next] net/core/dev: Warn on an impossibly short offload frame
Date: Tue, 05 Jan 2016 13:36:09 -0500
Message-ID: <f7tbn8z98me.fsf@aconole.bos.csb>
References: <1451780713-4098-1-git-send-email-aconole@bytheb.org>
	<1451783193.4334.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752513AbcAESgK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 13:36:10 -0500
In-Reply-To: <1451783193.4334.3.camel@perches.com> (Joe Perches's message of
	"Sat, 02 Jan 2016 17:06:33 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:
> On Sat, 2016-01-02 at 19:25 -0500, Aaron Conole wrote:
>> When signaling that a GRO frame is ready to be processed, the networ=
k stack
>> correctly checks length and aborts processing when a frame is less t=
han 14
>> bytes. However, such a condition is really indicative of a broken dr=
iver,
>> and should be loudly signaled, rather than silently dropped as the c=
ase is
>> today.
>>=20
>> Convert the condition to use WARN_ON() to ensure that the stack loud=
ly
>> complains about such broken drivers.
> []
>> diff --git a/net/core/dev.c b/net/core/dev.c
> []
>> @@ -4579,7 +4579,7 @@ static struct sk_buff *napi_frags_skb(struct
>> napi_struct *napi)
>> =C2=A0	eth =3D skb_gro_header_fast(skb, 0);
>> =C2=A0	if (unlikely(skb_gro_header_hard(skb, hlen))) {
>> =C2=A0		eth =3D skb_gro_header_slow(skb, hlen, 0);
>> -		if (unlikely(!eth)) {
>> +		if (WARN_ON(!eth)) {
>> =C2=A0			napi_reuse_skb(napi, skb);
>> =C2=A0			return NULL;
>> =C2=A0		}
>
> It's generally a good idea to use
> WARN_ON_RATELIMIT or WARN_ON_ONCE.

Okay, I'll respin switching to WARN_ON_RATELIMIT, if that's a better
approach.

Thanks for the review, Joe!
