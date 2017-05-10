From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Requirements for a shutdown function?
Date: Wed, 10 May 2017 14:47:23 -0700
Message-ID: <358a4a6f-5c47-dae8-38bf-67150cba1b07@gmail.com>
References: <49bee65f-2ea8-1787-9642-659a967df8f0@codeaurora.org>
 <1721db9b-ed60-4556-9aac-81f17e2c1849@gmail.com>
 <f995d5b3-2a5c-df08-3915-f77ab9203844@codeaurora.org>
 <c2cdef1a-768c-c890-d5b2-e1dae99e0f9d@gmail.com>
 <1efae594-427b-58e5-fd48-bac9f686bb52@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:32919 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752977AbdEJVr2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 17:47:28 -0400
Received: by mail-qk0-f196.google.com with SMTP id o85so1296688qkh.0
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 14:47:28 -0700 (PDT)
In-Reply-To: <1efae594-427b-58e5-fd48-bac9f686bb52@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 01:17 PM, Timur Tabi wrote:
> On 05/09/2017 02:06 PM, Florian Fainelli wrote:
>> On 05/09/2017 11:51 AM, Timur Tabi wrote:
> 
>>> Is it possible that the network stack detects a kexec and automatically
>>> stops all network devices?
>>
>> No. why would it? However the device driver model does call into your
>> driver's remove function and that one does a right job already because
>> it does an network device unregister, and so on.
> 
> I ran some more tests.  When I launch kexec, the driver's
> net_device_ops.ndo_stop function is called, which already stops the interface.
> 
> So it looks to me as if the network stack does close the interface during a
> kexec.  With the interface closed, there's no point in having a shutdown
> function, is there?

AFAIR kexec takes care of shutting down network devices explicitly
(unless instructed otherwise with -x/--no-ifdown) so this may be where
this is coming from.

Reading through drivers/base/core.c it does not appear that ->remove()
is called and then ->shutdown() gets called, only ->shutdown() gets
called from device_shutdown() called from kernel/reboot.c. It seems to
me like if you want to be on the safe side you would want to implement a
shutdown function that is identical to what your remove function does.

> 
>>> My in-house driver stops the RX and TX queues.  I'm guessing that's good
>>> enough, but I don't have a failing test case to prove it.
>>>
>>
>> That's probably good enough, yes.
> 
> Except that it turns out that the queues are already stopped by then because
> the emac_close() function has already been called.

-- 
Florian
