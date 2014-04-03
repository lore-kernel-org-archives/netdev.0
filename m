From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Thu, 03 Apr 2014 17:45:11 +0200
Message-ID: <533D8207.2050108@gmail.com>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de> <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com> <533C721E.1080004@gmail.com> <533C8B49.8080704@ahsoftware.de> <533C8ECB.4090900@gmail.com> <533D0B09.9040602@ahsoftware.de> <533D207E.9020909@gmail.com> <533D790C.5000104@ahsoftware.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	stable <stable@vger.kernel.org>
To: Alexander Holler <holler@ahsoftware.de>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533D790C.5000104@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/03/2014 05:06 PM, Alexander Holler wrote:
> Am 03.04.2014 10:49, schrieb Sebastian Hesselbarth:
>> On 04/03/2014 09:17 AM, Alexander Holler wrote:
>>> Am 03.04.2014 00:27, schrieb Sebastian Hesselbarth:
>>>> On 04/03/2014 12:12 AM, Alexander Holler wrote:
>>>>>> I am curious, how you determined above commit to be the cause of the
>>>>>> regression you are seeing. Can you bisect, if you didn't already?
>>>>>
>>>>> There was no bisecting necessary. I've just looked at what changed in
>>>>> mv643xx_eth since 3.13 and the first commit I've reverted was
>>>>> already a
>>>>> hit. Reading a bit source revealed the differences between the old
>>>>> reset
>>>>> and the newly used one and ended up with my patch (first try) and
>>>>> was a
>>>>> hit too.
>>>>
>>>> Honestly, your own fix changes a different driver than mv643xx_eth.
>>>
>>> It changes stuff which now (through the mentioned commit) gets used
>>> through the change in mv643xx_eth.
>>
>> Sigh. You have proven youself that the commit isn't the root cause
>> of the issue you are seeing. Nor is "fixing" 88e1116r init sequence
>> a reasonable fix.
>
> Sorry, continuing this discussion doesn't make sense. You have the same
> hw, so just try enabling netconsole with 3.14 and use dhcpcd from
> userland (this does the final reset here which hangs.
>
> But don't suggest me (or insist on) a time consuming and totally useless
> bisect when I already know what makes the problem to appear (100%
> reliable here).

I _suggest_ to use bisect, I don't _insist_. But for a patch that 
tackles an issue, knowing the offending patch is really good.

Now that you revealed more input, it becomes more clear to me what is
happening (although I have no clue, what netconsole really does to the
eth/phy):

- u-boot powers on the PHY
- netconsole picks up the eth device and the PHY, drops it later
- the PHY state machine powers off the now unused PHY (also introduced
   in between v3.13 and v3.14).
- dhcp client ifup's the device and tries to reset the powered down PHY

I already made a comment about the set POWERDOWN bit before, which you
silently ignored.

I will try to reproduce it and if I hit it, will do a bisect to find
(and fix) the offending patch.

> I have better ways to waste my time.

Like writing workarounds instead of fixing bugs?

Sebastian
