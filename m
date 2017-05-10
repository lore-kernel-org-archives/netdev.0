From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Requirements for a shutdown function?
Date: Wed, 10 May 2017 15:17:25 -0500
Message-ID: <1efae594-427b-58e5-fd48-bac9f686bb52@codeaurora.org>
References: <49bee65f-2ea8-1787-9642-659a967df8f0@codeaurora.org>
 <1721db9b-ed60-4556-9aac-81f17e2c1849@gmail.com>
 <f995d5b3-2a5c-df08-3915-f77ab9203844@codeaurora.org>
 <c2cdef1a-768c-c890-d5b2-e1dae99e0f9d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33926 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750897AbdEJUR1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 16:17:27 -0400
In-Reply-To: <c2cdef1a-768c-c890-d5b2-e1dae99e0f9d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2017 02:06 PM, Florian Fainelli wrote:
> On 05/09/2017 11:51 AM, Timur Tabi wrote:

>> Is it possible that the network stack detects a kexec and automatically
>> stops all network devices?
> 
> No. why would it? However the device driver model does call into your
> driver's remove function and that one does a right job already because
> it does an network device unregister, and so on.

I ran some more tests.  When I launch kexec, the driver's
net_device_ops.ndo_stop function is called, which already stops the interface.

So it looks to me as if the network stack does close the interface during a
kexec.  With the interface closed, there's no point in having a shutdown
function, is there?

>> My in-house driver stops the RX and TX queues.  I'm guessing that's good
>> enough, but I don't have a failing test case to prove it.
>>
> 
> That's probably good enough, yes.

Except that it turns out that the queues are already stopped by then because
the emac_close() function has already been called.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
