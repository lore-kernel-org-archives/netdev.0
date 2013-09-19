From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH net 1/3] slip/slcan: added locking in wakeup function
Date: Thu, 19 Sep 2013 06:43:16 -0400
Message-ID: <523AD544.7030100@hurleysoftware.com>
References: <1379093833-4949-1-git-send-email-nautsch2@gmail.com> <1379093833-4949-2-git-send-email-nautsch2@gmail.com> <523AC589.5040006@pengutronix.de> <523AD21C.8030102@gmail.com> <523AD356.70607@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andre Naujoks <nautsch2@gmail.com>, davem@davemloft.net,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <523AD356.70607@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ +cc Greg Kroah-Hartman]

On 09/19/2013 06:35 AM, Marc Kleine-Budde wrote:
> On 09/19/2013 12:29 PM, Andre Naujoks wrote:
>> On 19.09.2013 11:36, schrieb Marc Kleine-Budde:
>>> On 09/13/2013 07:37 PM, Andre Naujoks wrote:
>>>> The locking is needed, since the the internal buffer for the CAN
>>>> frames is changed during the wakeup call. This could cause buffer
>>>> inconsistencies under high loads, especially for the outgoing
>>>> short CAN packet skbuffs.
>>>>
>>>> The needed locks led to deadlocks before commit
>>>> "5ede52538ee2b2202d9dff5b06c33bfde421e6e4 tty: Remove extra
>>>> wakeup from pty write() path", which removed the direct callback
>>>> to the wakeup function from the tty layer.
>>>
>>> What does that mean for older kernels? (<
>>> 5ede52538ee2b2202d9dff5b06c33bfde421e6e4)
>>
>> It seems the slcan (and slip) driver is broken for older kernels. See
>> this thread for a discussion about the patch in pty.c.
>>
>> http://marc.info/?l=linux-kernel&m=137269017002789&w=2
>
> Thanks for the info.
>
>> The patch from Peter Hurley was actually already in the queue, when I
>> ran into the problem, and is now in kernel 3.12.
>>
>> Without the pty patch and slow CAN traffic, the driver works, because
>> the wakeup is called directly from the pty driver. That is also the
>> reason why there was no locking. It would just deadlock.
>>
>> When the pty driver defers the wakeup, we ran into synchronisation
>> problems (which should be fixed by the locking) and eventually into a
>> kernel panic because of a recursive loop (which should be fixed by the
>> pty.c patch).
>>
>> Maybe it is possible to get both patches back into the stable branches?
>
> Sounds reasonable. You might get in touch with Peter Hurley, if his
> patch is scheduled for stable. Documentation/stable_kernel_rules.txt
> suggests a procedure if your patch depends on others to be cherry picked.

Already following along.

I'd like to wait for 3.12 release before the pty patch goes to -stable
(so that it gets more in-the-wild testing).

Regards,
Peter Hurley
