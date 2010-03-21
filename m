From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Unable to create more than 1 guest virtio-net device using
	vhost-net backend
Date: Sun, 21 Mar 2010 12:15:27 +0200
Message-ID: <20100321101527.GH6443@redhat.com>
References: <1269037167.5127.12.camel@w-sridhar.beaverton.ibm.com> <20100321095544.GA6443@redhat.com> <4BA5F0D5.6020801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>, gleb@redhat.com
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5509 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752357Ab0CUKSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Mar 2010 06:18:55 -0400
Content-Disposition: inline
In-Reply-To: <4BA5F0D5.6020801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 21, 2010 at 12:11:33PM +0200, Avi Kivity wrote:
> On 03/21/2010 11:55 AM, Michael S. Tsirkin wrote:
>> On Fri, Mar 19, 2010 at 03:19:27PM -0700, Sridhar Samudrala wrote:
>>    
>>> When creating a guest with 2 virtio-net interfaces, i am running
>>> into a issue causing the 2nd i/f falling back to userpace virtio
>>> even when vhost is enabled.
>>>
>>> After some debugging, it turned out that KVM_IOEVENTFD ioctl()
>>> call in qemu is failing with ENOSPC.
>>> This is because of the NR_IOBUS_DEVS(6) limit in kvm_io_bus_register_dev()
>>> routine in the host kernel.
>>>
>>> I think we need to increase this limit if we want to support multiple
>>> network interfaces using vhost-net.
>>> Is there an alternate solution?
>>>
>>> Thanks
>>> Sridhar
>>>      
>> Nothing easy that I can see. Each device needs 2 of these.  Avi, Gleb,
>> any objections to increasing the limit to say 16?  That would give us
>> 5 more devices to the limit of 6 per guest.
>>    
>
> Increase it to 200, then.

OK. I think we'll also need a smarter allocator
than bus->dev_count++ than we now have. Right?

> Is the limit visible to userspace?  If not, we need to expose it.

I don't think it's visible: it seems to be used in a single
place in kvm. Let's add an ioctl? Note that qemu doesn't
need it now ...

> -- 
> error compiling committee.c: too many arguments to function
