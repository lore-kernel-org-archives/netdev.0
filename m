From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : convert network timestamps to ktime_t
Date: Mon, 05 Mar 2007 07:56:33 +0100
Message-ID: <45EBBF21.1000209@cosmosbay.com>
References: <200703021538.41284.dada1@cosmosbay.com>	<20070302130210.57883edc@freekitty>	<45E8A936.9050908@cosmosbay.com> <20070304.161924.55508971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, linux.kernel@free.fr,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54692 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbXCEG4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 01:56:53 -0500
In-Reply-To: <20070304.161924.55508971.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 02 Mar 2007 23:46:14 +0100
>=20
>> Stephen Hemminger a =E9crit :
>>> You missed a couple of spots.
>> Arg yes...
>  ...
>>> -	}
>>> -	skb_get_timestamp(skb, &svsk->sk_sk->sk_stamp);
>>> +	svsk->sk_sk->sk_stamp =3D (skb->tstamp.tv64 !=3D 0) ? skb->tstamp
>>> +		: ktime_get_real();
>> Well, if we want to stay in the spirit of old code, we probably want=
 to use=20
>> current_kernel_time() (+ timespec_to_ktime()), because its less expe=
nsive.
>>
>> And also setting the skb tstamp, no ?
>=20
> Can you guys cook up an integrated patch with all the missing cases
> fixed up as desired, so I can add this to net-2.6.22, thanks?

Yes, I will send the patch against net-2.6.22 this morning.
