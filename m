From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] SSB / B44: fix WOL for BCM4401
Date: Tue, 02 Dec 2014 16:23:49 -0600
Message-ID: <547E3BF5.5060201@lwfinger.net>
References: <20141201111125.GA11974@localhost.localdomain>	<1417466798-15735-1-git-send-email-Andrej.Skvortzov@gmail.com>	<20141201221023.79ffb40d@wiggum>	<20141202200129.GA4580@crion89> <20141202211211.7e08b935@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Gary.Zambrano@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev <b43-dev@lists.infradead.org>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: =?UTF-8?B?TWljaGFlbCBCw7xzY2g=?= <m@bues.ch>,
	Andrey Skvortsov <andrej.skvortzov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141202211211.7e08b935@wiggum>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/02/2014 02:12 PM, Michael B=C3=BCsch wrote:
> On Tue, 2 Dec 2014 23:01:29 +0300
> Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:
>
>> On Mon, Dec 01, 2014 at 10:10:23PM +0100, Michael B=C3=BCsch wrote:
>>> On Mon,  1 Dec 2014 23:46:38 +0300
>>> Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:
>>>
>>>> Wake On Lan was not working on laptop DELL Vostro 1500.
>>>> If WOL was turned on, BCM4401 was powered up in suspend mode. LEDs=
 blinked.
>>>> But the laptop could not be woken up with the Magic Packet. The re=
ason for
>>>> that was that PCIE was not enabled as a system wakeup source and
>>>> therefore the host PCI bridge was not powered up in suspend mode.
>>>> PCIE was not enabled in suspend by PM because no child devices wer=
e
>>>> registered as wakeup source during suspend process.
>>>> On laptop BCM4401 is connected through the SSB bus, that is connec=
ted to the
>>>> PCI-Express bus. SSB and B44 did not use standard PM wakeup functi=
ons
>>>> and did not forward wakeup settings to their parents.
>>>> To fix that B44 driver enables PM wakeup and registers new wakeup =
source
>>>> using device_set_wakeup_enable(). Wakeup is automatically reported=
 to the parent SSB
>>>> bus via power.wakeup_path. SSB bus enables wakeup for the parent P=
CI bridge, if there is any
>>>> child devices with enabled wakeup functionality. All other steps a=
re
>>>> done by PM core code.
>>>
>>> Thanks, this looks good.
>>> I assume you tested this (I currently don't have a device to test t=
his).
>>
>> Sure, I've tested it. WOL from suspend is working and after resume f=
rom hibernate Ethernet is working too.
>
> That sounds good, indeed.
> I'd still prefer, if someone with b43 (wireless) would test it, too.

I did a partial test with my PowerBook G4. With the patch installed, it=
 would=20
both suspend and hibernate, but WOL would be impossible. This computer =
uses a=20
PCMCIA version of the BCM4318, and power is turned off to the PCMCIA ca=
rd when=20
suspended or hibernating.

If WOL works for the OP, then I think we can ACK this patch.

Larry
