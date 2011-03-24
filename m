From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 19:14:51 +0100
Message-ID: <AANLkTik+Rf45wUxN86t+Zp7+AXjcJsy0vmZgvmLj-95x@mail.gmail.com>
References: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
	<1300980118.3747.42.camel@edumazet-laptop>
	<AANLkTikZhT5LaA-UEXniDvkneH8JScaVaCaCd4LT59cV@mail.gmail.com>
	<1300983340.3747.44.camel@edumazet-laptop>
	<1300986084.3747.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:46730 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab1CXSPC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 14:15:02 -0400
In-Reply-To: <1300986084.3747.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2011 at 6:01 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 24 mars 2011 =E0 17:15 +0100, Eric Dumazet a =E9crit :
>
>> I am testing following patch :
>>
>> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
>> index 622ac4c..654ef5b 100644
>> --- a/net/ipv4/fib_semantics.c
>> +++ b/net/ipv4/fib_semantics.c
>> @@ -251,7 +251,7 @@ static struct fib_info *fib_find_info(const stru=
ct fib_info *nfi)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfi->fib_prefsrc =3D=3D fi->fib_=
prefsrc &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfi->fib_priority =3D=3D fi->fib=
_priority &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcmp(nfi->fib_metrics, fi->fib=
_metrics,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(fi->fib_metr=
ics)) =3D=3D 0 &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(u32) * RTAX_=
MAX) =3D=3D 0 &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((nfi->fib_flags ^ fi->fib_flags=
) & ~RTNH_F_DEAD) =3D=3D 0 &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (nfi->fib_nhs =3D=3D 0 || nh_com=
p(fi, nfi) =3D=3D 0))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return fi;
>>
>>
>
> This works. Here is the formal submission :
>
> Thanks !
>
> [PATCH] ipv4: fix fib metrics
>
> Alessandro Suardi reported that we could not change route metrics :
>
> ip ro change default .... advmss 1400
>
> This regression came with commit 9c150e82ac50 (Allocate fib metrics
> dynamically). fib_metrics is no longer an array, but a pointer to an
> array.
>
> Reported-by: Alessandro Suardi <alessandro.suardi@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =A0net/ipv4/fib_semantics.c | =A0 =A02 +-
> =A01 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 622ac4c..75b9fb5 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -251,7 +251,7 @@ static struct fib_info *fib_find_info(const struc=
t fib_info *nfi)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfi->fib_prefsrc =3D=3D fi->fi=
b_prefsrc &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfi->fib_priority =3D=3D fi->f=
ib_priority &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcmp(nfi->fib_metrics, fi->f=
ib_metrics,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(fi->fib_m=
etrics)) =3D=3D 0 &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(u32) * RT=
AX_MAX) =3D=3D 0 &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((nfi->fib_flags ^ fi->fib_fla=
gs) & ~RTNH_F_DEAD) =3D=3D 0 &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(nfi->fib_nhs =3D=3D 0 || nh_c=
omp(fi, nfi) =3D=3D 0))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return fi;

Tested-by: Alessandro Suardi <alessandro.suardi@gmail.com>



I will however make one more bug report, as vpnc is broken before
 and after this patch - have to dig out what vpnc-script tries to do,
 which results in

Error: either "to" is duplicate, or "ipid" is a garbage.

 after establishing the VPN tunnel.


Thanks,

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")
