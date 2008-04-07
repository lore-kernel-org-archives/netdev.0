From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.26 1/2] Shrink size of net_device by filling alignment
 holes in it.
Date: Mon, 07 Apr 2008 19:17:11 +0200
Message-ID: <47FA5717.4070901@cosmosbay.com>
References: <47FA4ADE.1020308@openvz.org> <47FA5426.10704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([80.12.242.26]:54110 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751108AbYDGRR1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 13:17:27 -0400
In-Reply-To: <47FA5426.10704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Pavel Emelyanov a =E9crit :
>> I've found a much easier way to shrink the net_device structure=20
>> rather that moving all the operations out of it. However, since
>> the net_device may grow further, moving the operations into a
>> separate place may look reasonable.
>>
>> The pahole tool showed, that there are a 124 and 80 bytes holes
>> before the queue_lock and the _xmit_lock respectively. Moving most
>> of the devices callbacks into the 2nd hole makes the sizeof of the
>> structure be 1024 bytes.
>>
>>  =20
> On 32 bits platform and CONFIG_X86_L1_CACHE_SHIFT=3D7
> I presume :)
>
> Could you check if x86_64 machines with  X86_L1_CACHE_SHIFT =3D 7 or =
8=20
> dont suffer from this patch ?
>
> At first glance I would say it seems OK, but this net_device is reall=
y=20
> touchy for SMP performance :)
I meant :

X86_L1_CACHE_SHIFT =3D 6 (MK8 | MCORE2)  or 7 (others)





