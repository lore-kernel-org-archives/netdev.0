From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Thu, 28 Jan 2010 17:43:34 -0500
Message-ID: <4B621316.8070308@majjas.com>
References: <4B605D1B.60402@majjas.com> <20100127085049.5b5048e9@nehalam>
 <4B60707F.1000608@majjas.com> <20100127095614.14313677@nehalam>
 <4B608128.7090607@majjas.com> <4B6089C7.4010803@majjas.com>
 <4B61ADF1.7060705@majjas.com> <4B61BEA4.1030905@majjas.com>
 <20100128090835.0d93e53a@nehalam> <4B61DB79.4080703@majjas.com>
 <20100128223447.GC3109@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754353Ab0A1Wn3@vger.kernel.org>
In-reply-to: <20100128223447.GC3109@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/28/2010 5:34 PM, Jarek Poplawski wrote:
> On Thu, Jan 28, 2010 at 01:46:17PM -0500, Michael Breuer wrote:
>    
>> On 1/28/2010 12:08 PM, Stephen Hemminger wrote:
>>      
>>> --- a/lib/dma-debug.c	2010-01-20 15:22:55.919519883 -0800
>>> +++ b/lib/dma-debug.c	2010-01-20 15:26:31.648895638 -0800
>>> @@ -285,11 +285,9 @@ static struct dma_debug_entry *hash_buck
>>>   	}
>>>
>>>   	/*
>>> -	 * If we have multiple matches but no perfect-fit, just return
>>> -	 * NULL.
>>> +	 * If we have multiple matches but no perfect-fit
>>> +	 * return best value and let caller deal with it.
>>>   	 */
>>> -	ret = (matches == 1) ? ret : NULL;
>>> -
>>>   	return ret;
>>>   }
>>>
>>>        
>> Ok - applied. Noise gone... however I'm not sure whether I'll be
>> able to keep dma-debug going long enough to catch anything.
>> num_free_entries keeps dropping... looks like entries are not freed.
>> I'm running with a huge number for now&  sky2 as the driver filter.
>> Is there a reason that entries wouldn't be unmapped, or is
>> dma-debug.c just not processing the unmap correctly?
>>      
> Do you mean it's after this patch or earlier too? I think you might
> use my sky2/receive_copy/pci_unmap_len patch instead to get rid of
> this warning.
>
> Btw, since 1000 was too much, maybe you could try copybreak=256 yet,
> plus additional ping or some other source of shorter packets. And how
> about trying this new switch?
>
> Jarek P.
>    
This is with the pci_unmap_len patch as well as the dma-debug patch. I'm 
not getting any warnings - but dma-debug num-free-entries drops until 
zero and then debugging is disabled. I started with 8,000,000 about 
three hours ago - without load I'm already down to less than half that. 
Again - only looking at sky2. Looks like the dma-debug hash table is 
reducing one entry for every packet, but never increasing the 
num_entries (no unmap perhaps).
