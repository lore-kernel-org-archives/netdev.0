From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast groups
Date: Sun, 3 Jul 2011 19:30:33 +0100
Message-ID: <CAEJpZP10QCbKjk3sp7s7LuFHB8VMRwbpaamXwmFH3vH_NpmfMQ@mail.gmail.com>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
	<20110701223756.GG2613105@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62512 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664Ab1GCSae convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2011 14:30:34 -0400
Received: by pzk9 with SMTP id 9so1136144pzk.19
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2011 11:30:34 -0700 (PDT)
In-Reply-To: <20110701223756.GG2613105@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 July 2011 23:37, David Lamparter <equinox@diac24.net> wrote:
> On Fri, Jul 01, 2011 at 10:21:44PM +0100, Nick Carter wrote:
>> Introduce sysfs ../bridge/group_fwd_mask attribute so users can
>> configure which group mac addresses are forwarded.
>>
>> These diffs do not change the default behaviour of bridge.ko. =A0By
>> changing the group_fwd_mask value users can select any combination o=
f
>> the 01-80-C2-00-00-00 - 01-80-C2-00-00-0F addresses to be forwarded.
>>
>> Signed-off-by: Nick Carter <ncarter100@gmail.com>
>
> Hm. Makes it very easy to shoot yourself in the foot, but...
>
>> + =A0 =A0 br->group_fwd_mask =3D 0;
>
> ... but the default is safe, so we're following the unix philosophy o=
f
> handing out the gun to shoot yourself :)
>
> Reviewed-by: David Lamparter <equinox@diac24.net>
>
>
> PS:
>> @@ -166,6 +166,9 @@ struct sk_buff *br_handle_frame(struct sk_buff *=
skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->stp_enabled =3D=3D BR_NO_STP =
&& dest[5] =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto forward;
>
> Not sure if we still need the STP one when we have the mask, it shoul=
d
> probably go away for consistency. It would change existing behaviour
> though... either way it can be a separate patch.
Yes I agree.  Probably best to wait until the user space tools are
updated to support the new mask, so users can easily configure a
workaround to the change in behaviour.  I'm happy to update brctl to
support the mask, I pretty much have the diffs already.
Nick

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->group_fwd_mask & (1 << dest[5])=
)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto forward;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_=
IN, skb, skb->dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, br_handle_=
local_finish))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL; =A0 =A0/* f=
rame consumed by filter */
>
