From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Sun, 23 Jan 2005 19:08:34 +0000
Message-ID: <41F3F632.3060800@phekda.gotadsl.co.uk>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com> <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com> <41D2844E.5070204@phekda.gotadsl.co.uk> <20041229235203.GA5465@electric-eye.fr.zoreil.com> <41F250D1.8000207@phekda.gotadsl.co.uk> <41F26FD1.2060407@phekda.gotadsl.co.uk> <20050122230156.GC24461@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Me <rich@phekda.gotadsl.co.uk>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050122230156.GC24461@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Francois Romieu wrote:
> Richard Dawe <rich@phekda.gotadsl.co.uk> :
> [...]
> 
>>So I looked at the latest RealTek driver for Linux (version 220) and 
>>that has some separate initialisation code for RTL_GIGA_MAC_VER_X 
>>(MCFG_METHOD_4, they call it). I ported that over to r8169.c in 
>>2.6.11-rc1 and it appears to work.
> 
> 
> Nice. Have you checked that ethtool performs correctly when you try to
> set the link parameters with the new code (+ plug/unplug cable) ?

It detects the cable being removed and reinserted OK.

I can set the link speed and duplex fine using the "media=..." parameter 
on insmod.

My ADSL router doesn't have an interface (GUI or CLI) for setting the 
port speed and duplex. A Linksys WRT54GS wireless router is turning up 
tomorrow, so I may be able to set the port speed & duplex with that. But 
for now I can't test autodetection when the switch offers less than 
100Mbps full-duplex. I also have no GigE equipment to test with.

If I try setting the speed & duplex using something like this:

   ethtool -s eth0 speed 10 duplex half

it fails. I get no errors, but the "ethtool eth0" shows the link speed & 
duplex to be 100Mbps full-duplex. I think I managed to get it into 
100Mbps half-duplex once

When I try to "ethtool -s eth0 speed 10", the link lights on my ADSL 
router change to orange, which indicates 10Mbps. Then the light goes out 
and comes back green, which indicates 100Mbps.

So maybe the driver isn't waiting long enough for something.

>>Attached is the patch against 2.6.11-rc1. I'm not sure if it caters to 
>>your tastes. Maybe you'll want to rename RTL_GIGA_MAC_VER_X. 
> 
> 
> I'll change the braces placement, the tab/spaces mix and push it.
> 
> Please include something like the line below in your future patches:
> Signed-off-by: Richard Dawe <rich@phekda.gotadsl.co.uk>

Thanks, will do.

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
