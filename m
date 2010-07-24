From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next-2.6] pktgen: Optionally leak kernel memory
Date: Sat, 24 Jul 2010 06:18:07 -0700
Message-ID: <4C4AE80F.1040406@candelatech.com>
References: <4C4A224B.8080806@candelatech.com> <1279949024.2451.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52796 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696Ab0GXNSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 09:18:13 -0400
In-Reply-To: <1279949024.2451.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/2010 10:23 PM, Eric Dumazet wrote:
> Le vendredi 23 juillet 2010 =C3=A0 16:14 -0700, Ben Greear a =C3=A9cr=
it :
>> Some time back, someone added some memset() calls to pktgen to
>> keep from leaking memory contents to the network.
>>
>
> Well, someone might be me ;)
>
>> At least in our modified version of pktgen, this caused about 25%
>> performance degradation when sending 1514 byte pkts (multi-pkt =3D=3D=
 0)
>> on a pair of 10G ports.  It was easy enough to comment these memset
>> calls out of course.
>>
>> I don't mind if this patch stays in,
>> but thought I'd post my findings in case anyone else wonders why
>> their pktgen slowed down...
>>
>
> Thanks Ben
>
> Here is a patch adding a new pktgen flag, so that admins can choose
> speed if they want to, if they dont use clone_skb to reduce skb setup
> costs.

It looks fine to me, though I have not actually tested it.

> +Very fast mode
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +One knob to get very fast pktgen is the UNSAFE flag :
> +
> +flag UNSAFE
> +
> +This ask to pktgen to not clear content of packets before sending th=
em.
> +Note this is a security problem, and should be used only if really n=
eeded.
> +If packets are cloned (clone_skb 1000), clearing data cost is amorti=
zed so
> +this UNSAFE mode is less interesting.

I think most users of pktgen wouldn't be too concerned about leaking
memory content to the network.  It's a root-only test tool that can eas=
ily
saturate most networks and do horrible things like overflow switch CAM =
tables
by randomizing source/dest macs etc.  So, this warning might could be a=
 bit
more descriptive of how it is a security problem "arbitrary contents of=
 memory can be
sent across the network and may be sniffed by devices on the network, p=
otentially
revealing private information such as passwords and application data fo=
r applications
running on the machine running pktgen" instead of telling folks not to =
use it unless it's
really needed.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
