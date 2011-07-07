From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Thu, 7 Jul 2011 13:37:38 +0400
Message-ID: <CAB9v_DEfe6XnavbDB8Jj9XmSXt4MSs6sVUD4F1C8w8wsdqJjPA@mail.gmail.com>
References: <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110705164202.GD2959@hmsreliant.think-freely.org>
	<1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110705180650.GF2959@hmsreliant.think-freely.org>
	<1309889634.2545.2.camel@edumazet-laptop>
	<1309890775.2545.17.camel@edumazet-laptop>
	<1309891516.2545.23.camel@edumazet-laptop>
	<20110705195353.GG2959@hmsreliant.think-freely.org>
	<1309896147.2545.28.camel@edumazet-laptop>
	<1309896940.2545.34.camel@edumazet-laptop>
	<20110705220644.GB12118@hmsreliant.think-freely.org>
	<20110706173243.404d8599@maggie>
	<1309971379.2292.64.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAB9v_DFmXS7_0Sx7VgVzViMSqOTtpaqiKrBABcfARigZabr5fA@mail.gmail.com>
	<1310021286.2481.36.camel@edumazet-laptop>
	<CAB9v_DF1-q31Y57CUzinXOfGtNejoCAEJVc7u2ECWNLDj97ZPQ@mail.gmail.com>
	<1310030439.2127.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAB9v_DEYbPztDMr9m0B6A-a-q1gvECzX8g=B31xUp+D1_d5fZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Michael_B=C3=BCsch?= <m@bues.ch>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:61819 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104Ab1GGJhj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 05:37:39 -0400
Received: by vws1 with SMTP id 1so583842vws.19
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 02:37:38 -0700 (PDT)
In-Reply-To: <CAB9v_DEYbPztDMr9m0B6A-a-q1gvECzX8g=B31xUp+D1_d5fZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 7, 2011 at 13:34, Alexey Zaytsev <alexey.zaytsev@gmail.com>=
 wrote:
> On Thu, Jul 7, 2011 at 13:20, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>> Le jeudi 07 juillet 2011 =C3=A0 11:45 +0400, Alexey Zaytsev a =C3=A9=
crit :
>>> On Thu, Jul 7, 2011 at 10:48, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>>> > Le jeudi 07 juillet 2011 =C3=A0 10:32 +0400, Alexey Zaytsev a =C3=
=A9crit :
>>> >> Sorry, been busy for the last couple days. Any patches I should =
test?
>>> >
>>> > Please try :
>>> >
>>>
>>> Thanks. Seems to fail to initialize, getting this in dmesg:
>>>
>>> [ =C2=A0103.421577] b44 0000:02:0e.0: PCI INT A -> GSI 16 (level, l=
ow) -> IRQ 16
>>> [ =C2=A0103.440139] ssb: Core 0 found: Fast Ethernet (cc 0x806, rev=
 0x07,
>>> vendor 0x4243)
>>> [ =C2=A0103.440159] ssb: Core 1 found: V90 (cc 0x807, rev 0x03, ven=
dor 0x4243)
>>> [ =C2=A0103.440177] ssb: Core 2 found: PCI (cc 0x804, rev 0x0A, ven=
dor 0x4243)
>>> [ =C2=A0103.481128] ssb: Sonics Silicon Backplane found on PCI devi=
ce 0000:02:0e.0
>>> [ =C2=A0103.481532] b44: b44.c:v2.0
>>> [ =C2=A0103.502185] b44 ssb1:0: eth0: Broadcom 44xx/47xx 10/100Base=
T
>>> Ethernet 00:17:a4:dd:4e:93
>>> [ =C2=A0109.405071] b44 ssb1:0: eth0: powering down PHY
>>> [ =C2=A0112.816456] b44 ssb1:0: eth0: Link is up at 100 Mbps, full =
duplex
>>> [ =C2=A0112.816470] b44 ssb1:0: eth0: Flow control is off for TX an=
d off for RX
>>> [ =C2=A0112.952073] b44 ssb1:0: eth0: powering down PHY
>>> [ =C2=A0113.816148] b44 ssb1:0: eth0: Link is down
>>> [ =C2=A0114.953717] b44 ssb1:0: eth0: powering down PHY
>>> [ =C2=A0117.816246] b44 ssb1:0: eth0: Link is up at 100 Mbps, full =
duplex
>>> [ =C2=A0117.816260] b44 ssb1:0: eth0: Flow control is off for TX an=
d off for RX
>>> [ =C2=A0117.963238] b44 ssb1:0: eth0: powering down PHY
>>> [ =C2=A0118.816128] b44 ssb1:0: eth0: Link is down
>>> [ =C2=A0119.962817] b44 ssb1:0: eth0: powering down PHY
>>
>> Maybe this is the b44_init_hw() change :
>>
>> bw32(bp, B44_DMARX_PTR, 0);
>>
>> So please change this part
>>
>> Updated patch :
>
> Initializes fine now, but the transfer would stall every few seconds.
>
Err, wait a sec, patches the wrong version.
