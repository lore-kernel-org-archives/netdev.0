From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Unable to create more than 1 guest virtio-net device using
	vhost-net backend
Date: Sun, 21 Mar 2010 13:34:43 +0200
Message-ID: <20100321113443.GB12339@redhat.com>
References: <1269037167.5127.12.camel@w-sridhar.beaverton.ibm.com> <20100321095544.GA6443@redhat.com> <4BA5F0D5.6020801@redhat.com> <20100321101527.GH6443@redhat.com> <4BA5F50B.8080302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>, gleb@redhat.com
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023Ab0CULiL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Mar 2010 07:38:11 -0400
Content-Disposition: inline
In-Reply-To: <4BA5F50B.8080302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 21, 2010 at 12:29:31PM +0200, Avi Kivity wrote:
> On 03/21/2010 12:15 PM, Michael S. Tsirkin wrote:
>>>> Nothing easy that I can see. Each device needs 2 of these.  Avi, Gleb,
>>>> any objections to increasing the limit to say 16?  That would give us
>>>> 5 more devices to the limit of 6 per guest.
>>>>
>>>>        
>>> Increase it to 200, then.
>>>      
>> OK. I think we'll also need a smarter allocator
>> than bus->dev_count++ than we now have. Right?
>>    
>
> No, why?

We'll run into problems if devices are created/removed in random order,
won't we?

> Eventually we'll want faster scanning than the linear search we employ  
> now, though.

Yes I suspect with 200 entries we will :). Let's just make it 16 for
now?

>>> Is the limit visible to userspace?  If not, we need to expose it.
>>>      
>> I don't think it's visible: it seems to be used in a single
>> place in kvm. Let's add an ioctl? Note that qemu doesn't
>> need it now ...
>>    
>
> We usually expose limits via KVM_CHECK_EXTENSION(KVM_CAP_BLAH).  We can  
> expose it via KVM_CAP_IOEVENTFD (and need to reserve iodev entries for  
> those).
>
> -- 
> error compiling committee.c: too many arguments to function
