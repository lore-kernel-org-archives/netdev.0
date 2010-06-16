From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag" (802.1p
 packet)
Date: Wed, 16 Jun 2010 13:42:16 +0200
Message-ID: <4C18B898.4000307@trash.net>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>	 <1276466190.14011.223.camel@localhost>	 <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com>	 <1276534945.2074.11.camel@achroite.uk.solarflarecom.com>	 <4C1662C3.3070708@trash.net> <1276542772.2444.13.camel@edumazet-laptop>	 <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com> <1276679284.2632.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pedro Garcia <pedro.netdev@dondevamos.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38266 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758668Ab0FPLmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 07:42:20 -0400
In-Reply-To: <1276679284.2632.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mercredi 16 juin 2010 =C3=A0 10:49 +0200, Pedro Garcia a =C3=A9cri=
t :
>> Here it is again. I added the modifications in http://kerneltrap.org=
/mailarchive/linux-netdev/2010/5/23/6277868 for HW accelerated incoming=
 packets (it did not apply cleanly on the last version of
>> the kernel, so I applied manually). Now, if the VLAN 0 is not explic=
itly created by the user, VLAN 0 packets will be treated as no VLAN (80=
2.1p packets), instead of dropping them.
>>
>> The patch is now for two files: vlan_core (accel) and vlan_dev (non =
accel)
>>
>> I can not test on HW accelerated devices, so if someone can check it=
 I will appreciate (even though in the thread above it looked like yes)=
=2E For non accel I tessted in 2.6.26. Now the patch is for
>> net-next-2.6, and it compiles OK, but I a have to setup a test envir=
onment to check it is still OK (should, but better to test).
>>
>> Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>
>>    =20
>
> OK, the patch itself is correct.
>  =20

Yes, looks fine to me as well.

> Now, could you please send it again with a proper changelog ?
>
> In this changelog, please explain why patch is needed, and
> keep lines short (< 72 chars), like the one you did in your first mai=
l.
>
> I'll then add my Signed-off-by, since I wrote the accelerated part ;)
>
> Note : I wonder if another patch is needed, in case 8021q module is
> _not_ loaded. We probably should accept vlan 0 frames in this case ?
>  =20

I agree that this would be best for consistency, but that would mean
adding more special cases to __netif_receive_skb().
