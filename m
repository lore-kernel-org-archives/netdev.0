From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: don't update slot on skb alloc/dma mapping error
Date: Tue, 29 Oct 2013 09:28:56 +0100
Message-ID: <CACna6rzqwz_wp=9ayX6AUZvVSNwdAg-LniXtNwy9eRFDEoNspg@mail.gmail.com>
References: <BLU0-SMTP119F7A71B34291D1CC2486BAC090@phx.gbl>
	<CACna6rzxt2QMtLfD84pw7EtYqg1Qva4ah83hVQOKpeKy72bd5w@mail.gmail.com>
	<BLU0-SMTP200803D333FF3A2F15AB82DAC090@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: Nathan Hintz <nlhintz@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:57017 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807Ab3J2I24 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 04:28:56 -0400
Received: by mail-oa0-f48.google.com with SMTP id m17so4762904oag.7
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 01:28:56 -0700 (PDT)
In-Reply-To: <BLU0-SMTP200803D333FF3A2F15AB82DAC090@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/10/29 Nathan Hintz <nlhintz@hotmail.com>:
> On Tue, 29 Oct 2013 07:52:58 +0100
> Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> wrote:
>
>> 2013/10/29 Nathan Hintz <nlhintz@hotmail.com>:
>> > Don't update the slot in "bgmac_dma_rx_skb_for_slot" unless both t=
he
>> > skb alloc and dma mapping are successful; and free the newly alloc=
ated
>> > skb if a dma mapping error occurs.  This will prevent an skb leak =
upon
>> > returning when an error occurs.
>>
>> In case of bgmac_dma_rx_skb_for_slot failure we're giving up anyway
>> (and freeing everything), but with your patch code is simpler to
>> understand, so I'm OK with that.
>>
>> Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>>
>
> I might be misunderstanding; but it in the case of failure, it appear=
ed to me
> that the currently received packet was dropped and the old skb would =
continue
> to be assigned to the slot and would be used to receive future packet=
s (this
> would continue until bgmac_dma_rx_skb_for_slot was successful).

I was commenting on current usage (bgmac_dma_alloc), not my WIP patch
for bgmac_dma_rx_read :)

Your patch will be helpful for my bgmac_dma_rx_read rework.
