From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/5] ibmvnic: harden interrupt handler
Date: Thu, 26 Jan 2017 12:56:24 -0500 (EST)
Message-ID: <20170126.125624.243097121899163842.davem@davemloft.net>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
        <20170125.230413.830821835017116629.davem@davemloft.net>
        <0cea7654-6722-5e68-cd05-cc51bbf7a5ae@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wvoigt@us.ibm.com,
        jallen@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org,
        nfont@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754116AbdAZR4f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 12:56:35 -0500
In-Reply-To: <0cea7654-6722-5e68-cd05-cc51bbf7a5ae@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Thu, 26 Jan 2017 10:44:22 -0600

> On 01/25/2017 10:04 PM, David Miller wrote:
>> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
>> Date: Wed, 25 Jan 2017 15:02:19 -0600
>>
>>> Move most interrupt handler processing into a tasklet, and
>>> introduce a delay after re-enabling interrupts to fix timing
>>> issues encountered in hardware testing.
>>>
>>> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
>> I don't think you have any idea what the real problem is.  This looks
>> like a hack, at best.  Next patch you'll increase the delay to "20",
>> right?  And if that doesn't work you'll try "40".
>>
>> Or if you do know the reason, you need to explain it in detail in this
>> commit message so that we can properly evaluate this patch.
> 
> You're right, I should have given more explanation in the commit message about the bug encountered and our reasons for this sort of fix.  The issue is that there are some scenarios during the device init where multiple messages are sent by firmware in one interrupt request. 
> 
> We have observed behavior where messages are delayed, resulting in the interrupt handler completing before the delayed messages can be processed, fouling up the device bring-up in the device probing and elsewhere.  The goal of the delay is to buy some time for the hypervisor to forward all the CRQ messages from the firmware.

Then isn't there an event you can sleep and wait for, or a piece of state for
you to poll and test for in a timeout based loop?

This delay is a bad solution for the problem of waiting for A to happen
before you do B.
