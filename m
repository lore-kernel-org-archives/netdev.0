From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Requirements for a shutdown function?
Date: Wed, 10 May 2017 15:17:34 -0700
Message-ID: <e12ce1e7-6cc4-4b66-05db-674839733044@gmail.com>
References: <49bee65f-2ea8-1787-9642-659a967df8f0@codeaurora.org>
 <1721db9b-ed60-4556-9aac-81f17e2c1849@gmail.com>
 <f995d5b3-2a5c-df08-3915-f77ab9203844@codeaurora.org>
 <c2cdef1a-768c-c890-d5b2-e1dae99e0f9d@gmail.com>
 <1efae594-427b-58e5-fd48-bac9f686bb52@codeaurora.org>
 <358a4a6f-5c47-dae8-38bf-67150cba1b07@gmail.com>
 <54c18ee6-d748-59f7-fd6f-451559b86c0b@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34679 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdEJWRi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 18:17:38 -0400
Received: by mail-qt0-f195.google.com with SMTP id l39so684991qtb.1
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 15:17:37 -0700 (PDT)
In-Reply-To: <54c18ee6-d748-59f7-fd6f-451559b86c0b@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 03:11 PM, Timur Tabi wrote:
> On 05/10/2017 04:47 PM, Florian Fainelli wrote:
>> AFAIR kexec takes care of shutting down network devices explicitly
>> (unless instructed otherwise with -x/--no-ifdown) so this may be where
>> this is coming from.
>>
>> Reading through drivers/base/core.c it does not appear that ->remove()
>> is called and then ->shutdown() gets called, only ->shutdown() gets
>> called from device_shutdown() called from kernel/reboot.c. It seems to
>> me like if you want to be on the safe side you would want to implement a
>> shutdown function that is identical to what your remove function does.
> 
> I finally found a testcase where the shutdown function is useful.  If you do
> a "reboot -f", it will call shutdown but not close.

Correct yes. Sorry, I did not recall which one of kexec or reboot would
call it, but both would actually now that I looked at what happens on
one of my systems again.
-- 
Florian
