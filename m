From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: use after free bug in socket code
Date: Tue, 07 Jul 2009 14:15:01 +0200
Message-ID: <4A533C45.5000702@hartkopp.net>
References: <19020.39270.408816.360526@ipc1.ka-ro> <20090706.190709.214907244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LW@KARO-electronics.de, netdev@vger.kernel.org,
	urs.thuermann@volkswagen.de
To: David Miller <davem@davemloft.net>,
	Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:47012 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755211AbZGGMPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 08:15:03 -0400
In-Reply-To: <20090706.190709.214907244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Lothar Wa=DFmann <LW@KARO-electronics.de>
> Date: Thu, 2 Jul 2009 13:26:30 +0200
>=20
>> Hi,
>>
>> while developing a canbus driver (with kernel 2.6.30-rc4) I
>> encountered a use-after-free bug that led to the following crash (du=
e
>> to CONFIG_DEBUG_SLAB being enabled):
>  ...
>> With the following patch I could alleviate the problem and did not
>> find any negative side effects, but I'm not sure, whether this is th=
e
>> Right Thing(TM), since I'm not too familiar with the networking code=
:
>  ...
>> Any comments on this?
>=20
> A patch like this shouldn't be needed.
>=20
> Can one of the CAN folks look into this?

Hi Dave,

i did - but i had no concerns that Lothars remark was an appropriate re=
quest.

I'm not the socket layer expert but IMO this looks like something to be=
 fixed
in standard networking code.

The only thing we do in out private sk->sk_destruct function is:

   skb_queue_purge(&sk->sk_receive_queue);

As Urs is currently out of office, i added his private mail address ...

Regards,
Oliver

