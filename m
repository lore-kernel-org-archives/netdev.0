From: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH beta 1] 0/3] Fix race conditions in
	mrf24j40 interrupts
Date: Thu, 23 May 2013 19:54:12 +0200
Message-ID: <CAO+c-UVMoctgG2qM2EzOVJwsEY_2TT79J-AuzX-xrPkSUHrQtw@mail.gmail.com>
References: <CAO+c-UVJQJbmmmCS4hxAEYHKa8gEU1Bs=y+Rv_A75UHeBZxc+w@mail.gmail.com>
	<1369188080-8904-1-git-send-email-alan@signal11.us>
	<519C278F.5030809@signal11.us>
	<CAO+c-UV1bZZEE=9=7VVn3f1eLWzCpYCK9eZnnvzNwcPOKKtKLA@mail.gmail.com>
	<519DB8E6.4020709@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <519DB8E6.4020709-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

2013/5/23 Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>:
> On 5/22/13 4:32 PM, David Hauweele wrote:
>>
>> I cannot use level-triggered interrupts with GPIO on the RPi, so I
>> cannot test this specific patch.
>
>
> Is there another interrupt line you can tie into which does support
> level-trigger interrupts (INT0 or something)?

According to the datasheet it should be possible but the bcm2708 port
does not support it. I've been told that we shouldn't use level-triggered
interrupts in the first place.

>
>
>> However I agree with the idea of level-triggered interrupts, that
>> would fix all major problems related to missed interrupts.
>>
>> Beside this I'm running a ping -f since more than two hours now and it
>> seems to work well.
>>
>
> So that surprises me. I thought level-trigger interrupts were the thing that
> would fix this problem, and if you're not running with that patch, you just
> have the INIT_COMPLETION() fix (which you said didn't fix your issue) and
> the threaded interrupts patch, which I was fairly sure I had determined
> wasn't fixing any actual race-condition-related problems.

I should have been more clear about this. I've tested [PATCH 1/3]
which fixes the race condition with tx_complete. That is the
INIT_COMPLETION() fix. But it is still possible to miss an interrupt,
perhaps it just took longer this time. I ran the test again today and
it failed after 30 minutes.

I did not test [PATCH 2/3], that is the threaded IRQ. Instead I
removed interrupt enable/disable from the IRQ handler and the
workqueue. Without this the driver would fail within seconds of a ping
-f. Have you observed this too ? Perhaps this problem is specific to
the bcm2708 port.

David

>
> I'm glad, but surprised that you're no longer seeing issues.
>
> Alan.
>
>
>>
>> 2013/5/22 Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>:
>>>
>>> On 05/21/2013 10:01 PM, Alan Ott wrote:
>>>>
>>>> David Hauweele noticed that the mrf24j40 would hang arbitrarily after
>>>> some
>>>> period of heavy traffic.  Two race conditions were discovered, and the
>>>> driver was changed to use threaded interrupts, since the enable/disable
>>>> of
>>>> interrupts in the driver has recently been a lighning rod whenever
>>>> issues
>>>> arise related to interrupts (costing engineering time), and since
>>>> threaded
>>>> interrupts are the right way to do it.
>>>>
>>>> Alan Ott (3):
>>>>    mrf24j40: Move INIT_COMPLETION() to before packet transmission
>>>>    mrf24j40: Use threaded IRQ handler
>>>>    mrf24j40: Use level-triggered interrupts
>>>>
>>>>   drivers/net/ieee802154/mrf24j40.c | 31 +++++++++----------------------
>>>>   1 file changed, 9 insertions(+), 22 deletions(-)
>>>
>>>
>>> I forgot to add, I ran ping -f both ways all afternoon (6.5 hours), and
>>> it seems solid.
>>>
>

------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
