From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe NULLL pointer dereference on OOM condition, 2.6.31.7
Date: Tue, 12 Jan 2010 21:28:18 -0800
Message-ID: <4B4D59F2.4080909@candelatech.com>
References: <4B424825.2070608@candelatech.com> <alpine.WNT.2.00.1001121757040.3168@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48488 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab0AMF2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 00:28:21 -0500
In-Reply-To: <alpine.WNT.2.00.1001121757040.3168@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2010 06:13 PM, Brandeburg, Jesse wrote:
> On Mon, 4 Jan 2010, Ben Greear wrote:
>
>> This is on a hacked 2.6.31.7 kernel.  I'm testing an application that creates
>> 30,000+ TCP connections (to self).  The system is 64-bit with 12GB of RAM, but
>> it can still run out of usable RAM (say, when I start another 10k connections
>> to bring it up to 40k).
>>
>> It looks like something in ixgbe isn't properly checking for inability
>> to allocate (or to have previously allocated) an skb, or perhaps some other
>> chunk of memory:
>>
>> [root@ct503-10G-09 ~]# BUG: unable to handle kernel NULL pointer dereference at 00000000000000e8
>> IP: [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
>
> Hi Ben, thanks for the report, is there a chance you can run gdb on your
> kernel (was it compiled with debug info?) and check the
> gdb>  l *(ixgbe_clean_rx_irq+0xe4)
>
> Sorry I'm so slow to respond.
>
> it seems there are some unwind problems after the recent round of patches
> to remove skb_dma_map/unmap, but those were only introduced in 2.6.33-rc1.
> Before that we weren't aware of any failure path issues.
>
> I'm building a kernel now to see if I can figure out the offset where
> you're showing the problem.

I don't have symbols in mine currently..but I can re-compile tomorrow and attempt to
reproduce it.

I have a few patches from Intel developers in the ixgbe driver, so it's not
stock anymore.

I don't expect you to want to download my tree, but just in case you do, it's
at:

git clone git://dmz1.candelatech.com/linux-2.6.dev.31.y

I was using the 64-bit config file found in the /configs dir

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
