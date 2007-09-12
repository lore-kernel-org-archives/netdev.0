From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] [-MM, FIX] ixgbe: incorporate napi_struct changes from
 net-2.6.24.git
Date: Wed, 12 Sep 2007 16:29:40 -0700
Message-ID: <46E87664.6040905@intel.com>
References: <20070912181307.13189.33476.stgit@localhost.localdomain>	<20070912151643.cb0e070b.akpm@linux-foundation.org>	<46E86611.60307@intel.com> <20070912161419.f6764d34.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	jesse.brandeburg@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11157 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbXILX3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 19:29:41 -0400
In-Reply-To: <20070912161419.f6764d34.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Wed, 12 Sep 2007 15:20:01 -0700
> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
> 
>> Andrew Morton wrote:
>>> On Wed, 12 Sep 2007 11:13:07 -0700
>>> Auke Kok <auke-jan.h.kok@intel.com> wrote:
>>>
>>>> This incorporates the new napi_struct changes into ixgbe.
>>> I get a reject storm.
>>>
>>>> --- a/drivers/net/ixgbe/ixgbe_main.c
>>>> +++ b/drivers/net/ixgbe/ixgbe_main.c
>>>> @@ -557,14 +557,15 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
>>>>  	struct ixgbe_adapter *adapter = rxr->adapter;
>>>>  
>>>>  	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rxr->eims_value);
>>>> -	netif_rx_schedule(adapter->netdev);
>>>> +	netif_rx_schedule(adapter->netdev, &adapter->napi);
>>>>  	return IRQ_HANDLED;
>>>>  }
>>>>  
>>> For example, my copy of ixgbe_msix_clean_rx(), from
>>> git://lost.foo-projects.org/~aveerani/git/linux-2.6#ixgbe is:
>> please drop that tree, and get the one I posted last week instead:
>>
>> git://lost.foo-projects.org/~ahkok/linux-2.6 ixgbe-20070905-submission
> 
> I think I just ignored that branch.  It looks like some frozen-week-old
> snapshot, whereas I like to get the latest tip-of-tree.


I usually don't update the branches on that machine all that often, the machine 
is horribly slow and a git-checkout of a new branch takes 5 minutes. However, it 
*is* the very latest version of ixgbe and the one I intend to get Jeff to merge ;).

If you want to automatically pull all the changes I make for all the drivers, I 
would probably prefer going to a git.kernel.org tree instead, which is something 
I have been contemplating already, and I might just do so

in any case, you do want to drop the ~aveerani/git/linux-2.6#ixgbe branch, which 
is quite a bit older than that.

Auke
