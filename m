From: Alan Ott <alan@signal11.us>
Subject: Re: [PATCH beta 1] 0/3] Fix race conditions in mrf24j40 interrupts
Date: Thu, 23 May 2013 15:33:50 -0400
Message-ID: <519E6F1E.8000200@signal11.us>
References: <CAO+c-UVJQJbmmmCS4hxAEYHKa8gEU1Bs=y+Rv_A75UHeBZxc+w@mail.gmail.com> <1369188080-8904-1-git-send-email-alan@signal11.us> <519C278F.5030809@signal11.us> <CAO+c-UV1bZZEE=9=7VVn3f1eLWzCpYCK9eZnnvzNwcPOKKtKLA@mail.gmail.com> <519DB8E6.4020709@signal11.us> <CAO+c-UVMoctgG2qM2EzOVJwsEY_2TT79J-AuzX-xrPkSUHrQtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: David Hauweele <david@hauweele.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAO+c-UVMoctgG2qM2EzOVJwsEY_2TT79J-AuzX-xrPkSUHrQtw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2013 01:54 PM, David Hauweele wrote:
> 2013/5/23 Alan Ott <alan@signal11.us>:
>> On 5/22/13 4:32 PM, David Hauweele wrote:
>>>
>>> I cannot use level-triggered interrupts with GPIO on the RPi, so I
>>> cannot test this specific patch.
>>
>>
>> Is there another interrupt line you can tie into which does support
>> level-trigger interrupts (INT0 or something)?
> 
> According to the datasheet it should be possible but the bcm2708 port
> does not support it. I've been told that we shouldn't use level-triggered
> interrupts in the first place.


Who is "we," and why shouldn't we use level-triggered interrupts? The
CPU needs to detect whatever type of interrupt the attached hardware
generates.


> 
>>
>>
>>> However I agree with the idea of level-triggered interrupts, that
>>> would fix all major problems related to missed interrupts.
>>>
>>> Beside this I'm running a ping -f since more than two hours now and it
>>> seems to work well.
>>>
>>
>> So that surprises me. I thought level-trigger interrupts were the thing that
>> would fix this problem, and if you're not running with that patch, you just
>> have the INIT_COMPLETION() fix (which you said didn't fix your issue) and
>> the threaded interrupts patch, which I was fairly sure I had determined
>> wasn't fixing any actual race-condition-related problems.
> 
> I should have been more clear about this. I've tested [PATCH 1/3]
> which fixes the race condition with tx_complete. That is the
> INIT_COMPLETION() fix. But it is still possible to miss an interrupt,
> perhaps it just took longer this time. I ran the test again today and
> it failed after 30 minutes.
> 
> I did not test [PATCH 2/3], that is the threaded IRQ. Instead I
> removed interrupt enable/disable from the IRQ handler and the
> workqueue. Without this the driver would fail within seconds of a ping
> -f.


Without what? What do you mean by "without this?" Without the
enable/disable, or without the change that removes the enable/disable?


> Have you observed this too ? Perhaps this problem is specific to
> the bcm2708 port.
> 

What I observe right now is that it seems to work great (ping -f for 6.5
hours) when using the three patches in this patch set on a BeagleBone.

> 
>>
>> I'm glad, but surprised that you're no longer seeing issues.
>>
>> Alan.
>>
>>
>>>
>>> 2013/5/22 Alan Ott <alan@signal11.us>:
>>>>
>>>> On 05/21/2013 10:01 PM, Alan Ott wrote:
>>>>>
>>>>> David Hauweele noticed that the mrf24j40 would hang arbitrarily after
>>>>> some
>>>>> period of heavy traffic.  Two race conditions were discovered, and the
>>>>> driver was changed to use threaded interrupts, since the enable/disable
>>>>> of
>>>>> interrupts in the driver has recently been a lighning rod whenever
>>>>> issues
>>>>> arise related to interrupts (costing engineering time), and since
>>>>> threaded
>>>>> interrupts are the right way to do it.
>>>>>
>>>>> Alan Ott (3):
>>>>>    mrf24j40: Move INIT_COMPLETION() to before packet transmission
>>>>>    mrf24j40: Use threaded IRQ handler
>>>>>    mrf24j40: Use level-triggered interrupts
>>>>>
>>>>>   drivers/net/ieee802154/mrf24j40.c | 31 +++++++++----------------------
>>>>>   1 file changed, 9 insertions(+), 22 deletions(-)
>>>>
>>>>
>>>> I forgot to add, I ran ping -f both ways all afternoon (6.5 hours), and
>>>> it seems solid.
>>>>
>>
