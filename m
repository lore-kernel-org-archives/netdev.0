From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v4 2/9] bgmac: leave interrupts disabled as long as there
 is work to do
Date: Mon, 13 Apr 2015 17:06:13 +0200
Message-ID: <CACna6rzASVB-j8TxDzybC5FC+BhJFA-3e9LGTXqfP8FgSnH0bA@mail.gmail.com>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
	<1428933162-26763-2-git-send-email-nbd@openwrt.org>
	<CACna6rxgjUPdMsnhgvoRQLaOZ+T1epyvj3cDbZnYRtOeG0irtA@mail.gmail.com>
	<552BDACD.1050306@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36543 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932341AbbDMPGP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 11:06:15 -0400
Received: by iebrs15 with SMTP id rs15so66977318ieb.3
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 08:06:13 -0700 (PDT)
In-Reply-To: <552BDACD.1050306@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 April 2015 at 17:03, Felix Fietkau <nbd@openwrt.org> wrote:
> On 2015-04-13 16:34, Rafa=C5=82 Mi=C5=82ecki wrote:
>> On 13 April 2015 at 15:52, Felix Fietkau <nbd@openwrt.org> wrote:
>>> Always poll rx and tx during NAPI poll instead of relying on the st=
atus
>>> of the first interrupt. This prevents bgmac_poll from leaving unfin=
ished
>>> work around until the next IRQ.
>>> In my tests this makes bridging/routing throughput under heavy load=
 more
>>> stable and ensures that no new IRQs arrive as long as bgmac_poll us=
es up
>>> the entire budget.
>>
>> What do you think about keeping u32 int_status; and just updating it
>> at the end of bgmac_poll? In case you decide to implement multiple T=
X
>> queues, it may be cheaper to just check a single bit in memory inste=
ad
>> reading DMA ring status.
> Events might arrive in the mean time. I ran some tests, and not check=
ing
> the irq status for processing rx/tx gave me fewer total IRQs under lo=
ad.

But you do check the status, I mean the following line:
if (bgmac_read(bgmac, BGMAC_INT_STATUS) & (BGMAC_IS_TX0 | BGMAC_IS_RX))

Would it make sense to do
bgmac->int_status =3D bgmac_read(bgmac, BGMAC_INT_STATUS);
if (bgmac->int_status)
instead?
