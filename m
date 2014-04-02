From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Thu, 03 Apr 2014 00:12:25 +0200
Message-ID: <533C8B49.8080704@ahsoftware.de>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de> <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com> <533C721E.1080004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	stable <stable@vger.kernel.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:45570 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030526AbaDBWMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 18:12:37 -0400
In-Reply-To: <533C721E.1080004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 02.04.2014 22:25, schrieb Sebastian Hesselbarth:
> On 04/02/2014 09:01 PM, Florian Fainelli wrote:
>> 2014-04-02 2:09 GMT-07:00 Alexander Holler <holler@ahsoftware.de>:
>>> Am 02.04.2014 02:57, schrieb Florian Fainelli:
>>>> 2014-04-01 16:55 GMT-07:00 Alexander Holler <holler@ahsoftware.de>:
>>>>> Commit 7cd1463664c2a15721ff4ccfb61d4d970815cb3d (introduced with 3.14)
>>>>> changed the initialization of the mv643xx_eth driver to use phy_init_hw()
>>>>> to reset the PHY. Unfortunately the initialization for the 88E1116R PHY
>>>>> was broken such, that it used mdelay() instead of really waiting for a
>>>>> reset to finish.
>>
>> Can you resubmit with the following information:
>>
>> - you specify the commit that introduce the problem in parenthesis,
>> e.g: deadbeef ("dead: beef: cafe babe")
>> - put this dmesg snippet in your log message to clearly illustrate
>> what is happening
>> - clarify that the PHY needs to be polled in a comment in
>> m88e1116r_config_init()
>>
>> Meanwhile, it would be good if someone with access to this particular
>> PHY datasheet could look for known erratas, problems, non-standard
>> compliant behavior ....
> 
> Alexander,
> 
> I tried todays linux/master on Seagate Dockstar with Marvell 88E1116R
> (0x01410e40) and cannot reproduce any regression. I tried booting from
> tftp and usb, I also rebooted twice to see if there are any side
> effects - nothing - ethernet always comes up as expected.
> 
> I am curious, how you determined above commit to be the cause of the
> regression you are seeing. Can you bisect, if you didn't already?

There was no bisecting necessary. I've just looked at what changed in
mv643xx_eth since 3.13 and the first commit I've reverted was already a
hit. Reading a bit source revealed the differences between the old reset
and the newly used one and ended up with my patch (first try) and was a
hit too.

Actually I assumed the reset needs longer than the 500ms, but as the
printks revealed, the reset is much faster.
So the problem seems to be the much increased time (1s) the newly used
reset function idles in mdelay.

But I think I have found the real reason. and the change of the reset
just increased the chance the problem is hit (here with 100% success or
fail rate however you want to name it).

Just give me a day or two to find the time to verify my assumption (I
don't want to speculate) and maybe find a real fix for the problem. Of
course, I still like my patch because it greatly decreases the time
necessary for a reset (and the chance to hit the problem).

Regards,

Alexander Holler
