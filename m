From: Mike Sinkovsky <msink@permonline.ru>
Subject: Re: [PATCH v6 0/2] Ethernet drivers for WIZnet chips
Date: Tue, 03 Apr 2012 18:15:15 +0600
Message-ID: <4F7AE9D3.80204@permonline.ru>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru> <1333450726-24455-1-git-send-email-msink@permonline.ru> <1333453170.18626.65.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333453170.18626.65.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

03.04.2012 17:39, Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=
:
> On Tue, 2012-04-03 at 16:58 +0600, Mike Sinkovsky wrote:
>> Based on original driver from chip manufacturer, but nearly full rew=
ite.
>> Tested and used in production with Blackfin BF531 embedded processor=
=2E
>>
>> Signed-off-by: Mike Sinkovsky<msink@permonline.ru>
>> ---
>> v6:
>>   - remove (S0_TX_FSR<  skb->len) check in TX handler, it doesn't wo=
rk
>>     anyway. Chip can transmit only one frame with MTU 1500 at a time=
,
>>     and tx buffer size is bigger.
>
> So what happens if XXX frames are given to start_xmit() in a flood ?
>
> You removed any flow control, how can this work ?
>
> Device has an infinite queue ?

As I understand from datasheet, device doesn't have tx queue at all.
It have tx buffer, processor must save transmitted frame to it, and the=
n=20
save SEND command to command register. When transmission completed,=20
SENDOK bit in interrupt register will be set to '1', and interrupt=20
handler will be called.

So, according to datasheet, driver must stop queue in start_xmit()=20
routine, and wake in interrupt handler of SENDOK bit.
I tried this, and it basically works, but SOMETIMES, very rare, I see=20
tx_timeout().

And without any flow control - driver works perfectly.
Weird, don't know why.


--=20
Mike
