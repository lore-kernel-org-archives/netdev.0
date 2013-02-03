From: =?UTF-8?Q?J=C3=B6rg_Otte?= <jrg.otte@gmail.com>
Subject: Re: [3.8-rc] regression: NETDEV WATCHDOG: eth0 (r8169): transmit
 queue 0 timed out
Date: Sun, 3 Feb 2013 16:34:30 +0100
Message-ID: <CADDKRnACHgBOmw0qLE4zVzhq=Yw-1AYJ-JW0muxRCR3jZ=VoUQ@mail.gmail.com>
References: <CADDKRnBqxSwC7HUP_aN1QELrv2+7jnncXj7EP0Pqv8E8FFTpPw@mail.gmail.com>
	<20130105093718.GA938@electric-eye.fr.zoreil.com>
	<CADDKRnBCrDz2X=5qpGE+r92ZFX5cA+jnSGt3wS8TR0RE8hi1HA@mail.gmail.com>
	<20130105165735.GB4906@electric-eye.fr.zoreil.com>
	<CADDKRnCkDS5rMSSi12ti5PV_RSP6s3S15YOJz8b98ehcsyKaOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADDKRnCkDS5rMSSi12ti5PV_RSP6s3S15YOJz8b98ehcsyKaOA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/1/6 J=C3=B6rg Otte <jrg.otte@gmail.com>:
> 2013/1/5 Francois Romieu <romieu@fr.zoreil.com>:
>> Can you check if things improve with v3.8-rc2 after removing :
>>
>> 1. 9ecb9aabaf634677c77af467f4e3028b09d7bcda
>>    r8169: workaround for missing extended GigaMAC registers
>> 2. d64ec841517a25f6d468bde9f67e5b4cffdc67c7
>>    r8169: enable internal ASPM and clock request settings
>
> Doesn't help for this problem.
>
> However this fixes a second issue for me:
> In 3.7.1 at startup the link came up after 15 sec.:
> grep r8169 dmesg.3.7.1
> [    1.956842] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.957059] r8169 0000:02:00.0: irq 42 for MSI/MSI-X
> [    1.957161] r8169 0000:02:00.0 eth0: RTL8168evl/8111evl at..
> [    1.957163] r8169 0000:02:00.0 eth0: jumbo features [frames..
> [   13.575452] r8169 0000:02:00.0 eth0: link down
> [   13.575475] r8169 0000:02:00.0 eth0: link down
> [   15.181317] r8169 0000:02:00.0 eth0: link up
>
> In 3.8rc the time increased to 24 seconds:
> grep r8169 dmesg.3.8.0
> [    1.852546] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.852765] r8169 0000:02:00.0: irq 42 for MSI/MSI-X
> [    1.852872] r8169 0000:02:00.0 eth0: RTL8168evl/8111evl at...
> [    1.852874] r8169 0000:02:00.0 eth0: jumbo features [frames...
> [   14.150212] r8169 0000:02:00.0 eth0: link down
> [   14.150229] r8169 0000:02:00.0 eth0: link down
> [   24.140263] r8169 0000:02:00.0 eth0: link up
>
> But with this revert I get the old performance:
> dmesg | grep r8169
> [    1.816613] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.816832] r8169 0000:02:00.0: irq 42 for MSI/MSI-X
> [    1.816947] r8169 0000:02:00.0 eth0: RTL8168evl/8111evl at...
> [    1.816948] r8169 0000:02:00.0 eth0: jumbo features [frames...
> [   13.986401] r8169 0000:02:00.0 eth0: link down
> [   13.986422] r8169 0000:02:00.0 eth0: link down
> [   15.623631] r8169 0000:02:00.0 eth0: link up
>
> Thus I recommend to revert this too.
>
>> 3. e0c075577965d1c01b30038d38bf637b027a1df3
>>    r8169: enable ALDPS for power saving
>
> That's it! This fixes the problem for me!
>


We are closely before v3.8 and I didn't see a solution
so far.
What is the plan regarding this issue(s)?

Thanks, J=C3=B6rg
