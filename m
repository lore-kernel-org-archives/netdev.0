From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Thu, 03 Apr 2014 09:17:29 +0200
Message-ID: <533D0B09.9040602@ahsoftware.de>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de> <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com> <533C721E.1080004@gmail.com> <533C8B49.8080704@ahsoftware.de> <533C8ECB.4090900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	stable <stable@vger.kernel.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533C8ECB.4090900@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 03.04.2014 00:27, schrieb Sebastian Hesselbarth:
> On 04/03/2014 12:12 AM, Alexander Holler wrote:

>>> I am curious, how you determined above commit to be the cause of the
>>> regression you are seeing. Can you bisect, if you didn't already?
>>
>> There was no bisecting necessary. I've just looked at what changed in
>> mv643xx_eth since 3.13 and the first commit I've reverted was already a
>> hit. Reading a bit source revealed the differences between the old reset
>> and the newly used one and ended up with my patch (first try) and was a
>> hit too.
>
> Honestly, your own fix changes a different driver than mv643xx_eth.

It changes stuff which now (through the mentioned commit) gets used 
through the change in mv643xx_eth.

> There is a lot of changes from v3.13 to v3.14 and bisecting really
> helps to pin-point the one offending patch. As you can see from my
> tests with Dockstar, poking in the PHY driver may not be the right
> place to fix it.
>
>> Actually I assumed the reset needs longer than the 500ms, but as the
>> printks revealed, the reset is much faster.
>> So the problem seems to be the much increased time (1s) the newly used
>> reset function idles in mdelay.
>
> You assume that the PHY issue comes from waiting for too long _after_
> the reset? And again, the very same PHY on Dockstar is not affected.

Guess with which hardware I'm experiencing this problem? Hint: 
http://ahsoftware.de/dockstar/ ;)

>
>> But I think I have found the real reason. and the change of the reset
>> just increased the chance the problem is hit (here with 100% success or
>> fail rate however you want to name it).
>>
>> Just give me a day or two to find the time to verify my assumption (I
>> don't want to speculate) and maybe find a real fix for the problem. Of
>> course, I still like my patch because it greatly decreases the time
>> necessary for a reset (and the chance to hit the problem).
>
> Well, you can share your idea anytime. You already speculated that PHY
> reset on 88e1116r is broken but it seems that is not true. The more
> you share of your issue and the tries to fix it, the more likely is it
> we can follow your patch immediately.

Sorry, but wild speculating doesn't help always. Otherwise I could 
mention several dozen possible reasons, starting from broken memory or 
other hw up to some memory corruption elsewhere in the kernel.

But I already have given a hint before, try what happens if you enable 
netconsole (compiled in) through the kernel commandline 
(netconsole=...). Maybe the ethernet on your dockstar will get stuck too.

>
> Again, if you really want to find the real patch breaking Sheevaplug,
> use git bisect.

That's silly if I already know a/the change which brings the problem to 
light. If I revert the mentioned commit the problem disapears. So why 
should I go through the pain to bisect stuff? I already have found the 
knob to kill the ethernet on that machine.

Regards,

Alexander Holler
