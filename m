From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: Tue, 06 Feb 2007 22:35:19 +0100
Message-ID: <45C8F497.2020700@cosmosbay.com>
References: <20070103163627.14635.88250.stgit@nienna.balabit>
 <45A48BEB.2070207@trash.net> <200702061536.18800@nienna>
 <20070206.114659.107250775.davem@davemloft.net>
 <45C8EAC4.9020803@cosmosbay.com> <1170799541.3535.25.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604005mt.neufgp.fr ([84.96.92.11]:36874 "EHLO smtp.Neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965406AbXBFVow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 16:44:52 -0500
Received: from [192.168.30.11] ([88.139.66.191]) by sp604005mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0JD200FF79B01190@sp604005mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Tue, 06 Feb 2007 22:35:44 +0100 (CET)
In-reply-to: <1170799541.3535.25.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan a =E9crit :
> On Tue, 2007-02-06 at 21:53 +0100, Eric Dumazet wrote:
>=20
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> plain text document attachment (tg3_avoid_divide.patch)
>> --- linux-2.6.20/drivers/net/tg3.c.orig	2007-02-06 22:30:39.00000000=
0 +0100
>> +++ linux-2.6.20-ed/drivers/net/tg3.c	2007-02-06 22:32:42.000000000 =
+0100
>> @@ -3384,7 +3384,7 @@
>>  		}
>>  next_pkt_nopost:
>>  		sw_idx++;
>> -		sw_idx %=3D TG3_RX_RCB_RING_SIZE(tp);
>> +		sw_idx &=3D (TG3_RX_RCB_RING_SIZE(tp) - 1);
>> =20
>>  		/* Refresh hw_idx to see if there is new work */
>>  		if (sw_idx =3D=3D hw_idx) {
>=20
> There are other places doing similar divide (e.g. tg3_recycle_rx(),
> tg3_alloc_rx_skb()).  I think we should change them all.

Well, I checked whole tg3.o with objdump --disassemble and there are on=
ly=20
three points using a div : tg3_nvram_phys_addr()/tg3_set_eeprom() &
tg3_open(), wich are seldom used :)

Eric
