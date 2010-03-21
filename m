From: Avi Kivity <avi@redhat.com>
Subject: Re: Unable to create more than 1 guest virtio-net device using vhost-net
 backend
Date: Sun, 21 Mar 2010 12:31:56 +0200
Message-ID: <4BA5F59C.5070403@redhat.com>
References: <1269037167.5127.12.camel@w-sridhar.beaverton.ibm.com> <20100321095544.GA6443@redhat.com> <4BA5F0D5.6020801@redhat.com> <20100321102143.GC13522@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Sridhar Samudrala <samudrala.sridhar@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Gleb Natapov <gleb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152Ab0CUKb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Mar 2010 06:31:59 -0400
In-Reply-To: <20100321102143.GC13522@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2010 12:21 PM, Gleb Natapov wrote:
> On Sun, Mar 21, 2010 at 12:11:33PM +0200, Avi Kivity wrote:
>    
>> On 03/21/2010 11:55 AM, Michael S. Tsirkin wrote:
>>      
>>> On Fri, Mar 19, 2010 at 03:19:27PM -0700, Sridhar Samudrala wrote:
>>>        
>>>> When creating a guest with 2 virtio-net interfaces, i am running
>>>> into a issue causing the 2nd i/f falling back to userpace virtio
>>>> even when vhost is enabled.
>>>>
>>>> After some debugging, it turned out that KVM_IOEVENTFD ioctl()
>>>> call in qemu is failing with ENOSPC.
>>>> This is because of the NR_IOBUS_DEVS(6) limit in kvm_io_bus_register_dev()
>>>> routine in the host kernel.
>>>>
>>>> I think we need to increase this limit if we want to support multiple
>>>> network interfaces using vhost-net.
>>>> Is there an alternate solution?
>>>>
>>>> Thanks
>>>> Sridhar
>>>>          
>>> Nothing easy that I can see. Each device needs 2 of these.  Avi, Gleb,
>>> any objections to increasing the limit to say 16?  That would give us
>>> 5 more devices to the limit of 6 per guest.
>>>        
>> Increase it to 200, then.
>>
>>      
> Currently on each device read/write we iterate over all registered
> devices. This is not scalable.
>    

Yeah.  We need first to drop the callback based matching and replace it 
with explicit ranges, then to replace the search with a hash table for 
small ranges (keeping a linear search for large ranges, can happen for 
coalesced mmio).

-- 
error compiling committee.c: too many arguments to function

