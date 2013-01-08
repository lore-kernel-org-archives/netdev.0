From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4] bgmac: driver for GBit MAC core on BCMA bus
Date: Mon, 07 Jan 2013 22:21:52 -0800 (PST)
Message-ID: <20130107.222152.1296444483411794560.davem@davemloft.net>
References: <1357431609-27981-1-git-send-email-zajec5@gmail.com>
	<20130107.194011.1849511206295563088.davem@davemloft.net>
	<CACna6rxknwzwvrZZp5++10-ZLLjUf2TMuO7d7vzxqJM2nxtckA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, joe@perches.com
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab3AHGVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 01:21:54 -0500
In-Reply-To: <CACna6rxknwzwvrZZp5++10-ZLLjUf2TMuO7d7vzxqJM2nxtckA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Tue, 8 Jan 2013 06:51:13 +0100

> 2013/1/8 David Miller <davem@davemloft.net>:
>> From: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
>> Date: Sun,  6 Jan 2013 01:20:09 +0100
>>
>>> V4: stop queue when ring is full
>>
>> You're still not doing it right.
>>
>>> +     if (free_slots =3D=3D 1) { /* Should never happen (netif_stop=
_queue) */
>>> +             bgmac_err(bgmac, "TX after stopping queue!\n");
>>> +             return NETDEV_TX_BUSY;
>>> +     }
>>
>> You need to call netif_stop_queue() in this code path too.
>=20
> In case of (free_slots =3D=3D 1) the queue should already be stopped =
by
> the previous xmit call (at the end). I didn't know it make sens to tr=
y
> stopping it again.

It obviously is not stopped, otherwise this function wouldn't get
called.
