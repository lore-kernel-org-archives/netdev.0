From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 16:27:44 +0300
Message-ID: <49D4BD50.4070402@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au> <49D4B4A3.5070008@novell.com> <49D4B87D.2000202@redhat.com> <49D4BBFA.2040106@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D4BBFA.2040106@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> Avi Kivity wrote:
>   
>> Gregory Haskins wrote:
>>     
>>> Rusty Russell wrote:
>>>  
>>>       
>>>> On Thursday 02 April 2009 21:36:07 Gregory Haskins wrote:
>>>>      
>>>>         
>>>>> You do not need to know when the packet is copied (which I currently
>>>>> do).  You only need it for zero-copy (of which I would like to
>>>>> support,
>>>>> but as I understand it there are problems with the reliability of
>>>>> proper
>>>>> callback (i.e. skb->destructor).
>>>>>           
>>>>>           
>>>> But if you have a UP guest,
>>>>     
>>>>         
>>> I assume you mean UP host ;)
>>>
>>>   
>>>       
>> I think Rusty did mean a UP guest, and without schedule-and-forget.
>>     
> That doesnt make sense to me, tho.  All the testing I did was a UP
> guest, actually.  Why would I be constrained to run without the
> scheduling unless the host was also UP?
>   

You aren't constrained.  And your numbers show it works.

>>
>> The problem is that we already have virtio guest drivers going several
>> kernel versions back, as well as Windows drivers.  We can't keep
>> changing the infrastructure under people's feet.
>>     
>
> Well, IIUC the virtio code itself declares the ABI as unstable, so there
> technically *is* an out if we really wanted one.  But I certainly
> understand the desire to not change this ABI if at all possible, and
> thus the resistance here.
>   

virtio is a stable ABI.

> However, theres still the possibility we can make this work in an ABI
> friendly way with cap-bits, or other such features.  For instance, the
> virtio-net driver could register both with pci and vbus-proxy and
> instantiate a device with a slightly different ops structure for each or
> something.  Alternatively we could write a host-side shim to expose vbus
> devices as pci devices or something like that.
>   

Sounds complicated...

-- 
error compiling committee.c: too many arguments to function

