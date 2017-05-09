From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Requirements for a shutdown function?
Date: Tue, 9 May 2017 12:06:48 -0700
Message-ID: <c2cdef1a-768c-c890-d5b2-e1dae99e0f9d@gmail.com>
References: <49bee65f-2ea8-1787-9642-659a967df8f0@codeaurora.org>
 <1721db9b-ed60-4556-9aac-81f17e2c1849@gmail.com>
 <f995d5b3-2a5c-df08-3915-f77ab9203844@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35356 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752564AbdEITGw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 15:06:52 -0400
Received: by mail-qt0-f195.google.com with SMTP id r58so1209953qtb.2
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 12:06:51 -0700 (PDT)
In-Reply-To: <f995d5b3-2a5c-df08-3915-f77ab9203844@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2017 11:51 AM, Timur Tabi wrote:
> On 05/09/2017 01:46 PM, Florian Fainelli wrote:
>> A good test case for exercising a .shutdown() function is kexec'ing a
>> new kernel for instance.
> 
> I tried that.  I run iperf in one window while launching kexec in another.
> Even without a shutdown function, network traffic appear to halt on its own
> and the kexec succeeds.
> 
> Is it possible that the network stack detects a kexec and automatically
> stops all network devices?

No. why would it? However the device driver model does call into your
driver's remove function and that one does a right job already because
it does an network device unregister, and so on.

There is no strict requirement for implementing a .shutdown() function
AFAICT and it does not necessarily make sense to have one depending on
the bus type. For platform/MMIO devices, it hardly has any value, but on
e.g: PCI, it could be added as an additional step to perform a full
device shutdown.

> 
>> You should put your HW in a state where it won't be doing DMA, or have
>> any adverse side effects to the system, putting it in a low power state
>> is also a good approach.
> 
> My in-house driver stops the RX and TX queues.  I'm guessing that's good
> enough, but I don't have a failing test case to prove it.
> 

That's probably good enough, yes.
-- 
Florian
