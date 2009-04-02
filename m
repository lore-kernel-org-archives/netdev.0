From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 17:32:01 +0300
Message-ID: <49D4CC61.6010105@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com> <49D4C191.2070502@redhat.com> <49D4CAA7.3020004@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760073AbZDBOcg@vger.kernel.org>
In-Reply-To: <49D4CAA7.3020004@novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
>> If you have a request-response workload with the wire idle and latency
>> critical, then there's no problem having an exit per packet because
>> (a) there aren't that many packets and (b) the guest isn't doing any
>> batching, so guest overhead will swamp the hypervisor overhead.
>>     
> Right, so the trick is to use an algorithm that adapts here.  Batching
> solves the first case, but not the second.  The bidir napi thing solves
> both, but it does assume you have ample host processing power to run the
> algorithm concurrently.  This may or may not be suitable to all
> applications, I admit.
>   

The alternative is to get a notification from the stack that the packet 
is done processing.  Either an skb destructor in the kernel, or my new 
API that everyone is not rushing out to implement.

>>> Right now its way way way worse than 2us.  In fact, at my last reading
>>> this was more like 3060us (3125-65).  So shorten that 3125 to 67 (while
>>> maintaining line-rate) and I will be impressed.  Heck, shorten it to
>>> 80us and I will be impressed.
>>>   
>>>       
>> The 3060us thing is a timer, not cpu time.
>>     
> Agreed, but its still "state of the art" from an observer perspective. 
> The reason "why", though easily explainable, is inconsequential to most
> people.  FWIW, I have seen virtio-net do a much more respectable 350us
> on an older version, so I know there is plenty of room for improvement.
>   

All I want is the notification, and the timer is headed into the nearest 
landfill.


-- 
error compiling committee.c: too many arguments to function
