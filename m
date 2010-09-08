From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: Kernel Panic on OOM with 10 HTB rules
Date: Wed, 08 Sep 2010 17:02:29 +0200
Message-ID: <4C87A585.5090109@ans.pl>
References: <AANLkTinQbuN4Y6yUgHhjhOkLGe3GPk9aN5z1gasvQ-zW@mail.gmail.com>	 <1283949778.2748.5.camel@edumazet-laptop>	 <AANLkTimDW-tuTJagnpkFq3TX4t+c_-9UUyG8z-bwPuJ1@mail.gmail.com> <1283957137.2748.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anand Raj Manickam <anandrm@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:46080 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab0IHPCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 11:02:32 -0400
In-Reply-To: <1283957137.2748.71.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-08 16:45, Eric Dumazet wrote:
<CUT>
> Thanks
>
> You are running a 32bit kernel, so kernel can _not_ use more than 800
> Mbytes of memory (Lowmem) for his own needs (including all network
> buffers)
>
> If you cannot switch to 64bit kernel, then you are forced to use lowe=
r
> queue lengths (I see your imq devices use insane 11000 txqueuelen)
>
> Each frame use 4K, maybe 16K, it depends on MTU.
>
> even if we dont take into account other needs :
> 11000 * 16K =3D 170 Mbytes per imqX
> 1000 * 4K =3D 4Mbytes per ethX
>
> 170M * 8 ->  memory overflow
>
> Also /proc/sys/vm/min_free_kbytes  limit is probably too small.
>
> Really, using a 32bit kernel on this machine is not wise.
>
> Even reducing physical ram to 4GB would be better, you would get more
> Lowmem memory ;)
>
> Since vmalloc is not used very much on your machine you can reduce
> vmalloc window from 128M to 32M to save 96MB of low mem
> (boot parameter : vmalloc=3D32M )

It is also possible to build a kernel using 2G/2G MEM SPLIT or even=20
1G/3G if there is small userspace activity. But indeed, x86-64 is the=20
proper solution to choose.

Best regards,

			Krzysztof Ol=C4=99dzki
