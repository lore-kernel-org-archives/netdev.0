From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Requirements for a shutdown function?
Date: Wed, 10 May 2017 17:11:19 -0500
Message-ID: <54c18ee6-d748-59f7-fd6f-451559b86c0b@codeaurora.org>
References: <49bee65f-2ea8-1787-9642-659a967df8f0@codeaurora.org>
 <1721db9b-ed60-4556-9aac-81f17e2c1849@gmail.com>
 <f995d5b3-2a5c-df08-3915-f77ab9203844@codeaurora.org>
 <c2cdef1a-768c-c890-d5b2-e1dae99e0f9d@gmail.com>
 <1efae594-427b-58e5-fd48-bac9f686bb52@codeaurora.org>
 <358a4a6f-5c47-dae8-38bf-67150cba1b07@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53102 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753089AbdEJWLW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 18:11:22 -0400
In-Reply-To: <358a4a6f-5c47-dae8-38bf-67150cba1b07@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 04:47 PM, Florian Fainelli wrote:
> AFAIR kexec takes care of shutting down network devices explicitly
> (unless instructed otherwise with -x/--no-ifdown) so this may be where
> this is coming from.
> 
> Reading through drivers/base/core.c it does not appear that ->remove()
> is called and then ->shutdown() gets called, only ->shutdown() gets
> called from device_shutdown() called from kernel/reboot.c. It seems to
> me like if you want to be on the safe side you would want to implement a
> shutdown function that is identical to what your remove function does.

I finally found a testcase where the shutdown function is useful.  If you do
a "reboot -f", it will call shutdown but not close.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
