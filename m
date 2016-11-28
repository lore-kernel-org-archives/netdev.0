From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [PATCH] net: macb: Write only necessary bits in NCR in macb reset
Date: Mon, 28 Nov 2016 15:10:50 +0530
Message-ID: <CAFcVEC+T_m710aT5pcOEMfzRL=DYtRyLi6sO7r-UUiChs4qXKw@mail.gmail.com>
References: <1480325029-39224-1-git-send-email-harinik@xilinx.com> <ddb3f476-928d-e235-3e7e-e78434074b04@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Harini Katakam <harini.katakam@xilinx.com>, davem@davemloft.net,
        netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "michals@xilinx.com" <michals@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33374 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753232AbcK1Jkz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 04:40:55 -0500
In-Reply-To: <ddb3f476-928d-e235-3e7e-e78434074b04@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

On Mon, Nov 28, 2016 at 3:01 PM, Nicolas Ferre <nicolas.ferre@atmel.com> wr=
ote:
> Le 28/11/2016 =C3=A0 10:23, Harini Katakam a =C3=A9crit :
>> In macb_reset_hw, use read-modify-write to disable RX and TX.
>> This way exiting settings and reserved bits wont be disturbed.
>
> Yes, indeed... but I would have liked a line about how you discovered it
> was an issue for you ;  what did it break, etc...

Thanks for the review.
It did not necessarily break anything but we noticed
during some experiments that management port was being
enabled and disabled.
In addition, I thought it would be good to do
just because there were reserved read only bits in
the register.

>
>> Use the same method for clearing statistics as well.
>>
>> Signed-off-by: Harini Katakam <harinik@xilinx.com>
>> ---
>>  drivers/net/ethernet/cadence/macb.c | 9 ++++++---
>>  1 file changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/=
cadence/macb.c
>> index 0e489bb..80ccfc4 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -1743,15 +1743,18 @@ static void macb_init_rings(struct macb *bp)
>>  static void macb_reset_hw(struct macb *bp)
>>  {
>>       struct macb_queue *queue;
>> -     unsigned int q;
>> +     unsigned int q, ctrl;
>
> I would have preferred a different line with u32 type.

Sure, I'll add and send a v2

Regards,
Harini
