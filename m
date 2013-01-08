From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH V4] bgmac: driver for GBit MAC core on BCMA bus
Date: Tue, 8 Jan 2013 06:51:13 +0100
Message-ID: <CACna6rxknwzwvrZZp5++10-ZLLjUf2TMuO7d7vzxqJM2nxtckA@mail.gmail.com>
References: <1357431609-27981-1-git-send-email-zajec5@gmail.com>
	<20130107.194011.1849511206295563088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:51935 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab3AHF40 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 00:56:26 -0500
Received: by mail-wg0-f47.google.com with SMTP id dq11so22249wgb.2
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 21:56:25 -0800 (PST)
In-Reply-To: <20130107.194011.1849511206295563088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/8 David Miller <davem@davemloft.net>:
> From: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Date: Sun,  6 Jan 2013 01:20:09 +0100
>
>> V4: stop queue when ring is full
>
> You're still not doing it right.
>
>> +     if (free_slots =3D=3D 1) { /* Should never happen (netif_stop_=
queue) */
>> +             bgmac_err(bgmac, "TX after stopping queue!\n");
>> +             return NETDEV_TX_BUSY;
>> +     }
>
> You need to call netif_stop_queue() in this code path too.

In case of (free_slots =3D=3D 1) the queue should already be stopped by
the previous xmit call (at the end). I didn't know it make sens to try
stopping it again.


> Look more carefully at the drivers we asked you to use as
> a model, they all do this properly.

Sorry, I obviously have problems understanding that :| I thought it's
enough to stop the queue at the end of xmit.

--=20
Rafa=C5=82
