From: Avi Kivity <avi@redhat.com>
Subject: Re: Unable to create more than 1 guest virtio-net device using	vhost-net
 backend
Date: Sun, 21 Mar 2010 12:29:31 +0200
Message-ID: <4BA5F50B.8080302@redhat.com>
References: <1269037167.5127.12.camel@w-sridhar.beaverton.ibm.com> <20100321095544.GA6443@redhat.com> <4BA5F0D5.6020801@redhat.com> <20100321101527.GH6443@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>, gleb@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100321101527.GH6443@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/2010 12:15 PM, Michael S. Tsirkin wrote:
>>> Nothing easy that I can see. Each device needs 2 of these.  Avi, Gleb,
>>> any objections to increasing the limit to say 16?  That would give us
>>> 5 more devices to the limit of 6 per guest.
>>>
>>>        
>> Increase it to 200, then.
>>      
> OK. I think we'll also need a smarter allocator
> than bus->dev_count++ than we now have. Right?
>    

No, why?

Eventually we'll want faster scanning than the linear search we employ 
now, though.

>> Is the limit visible to userspace?  If not, we need to expose it.
>>      
> I don't think it's visible: it seems to be used in a single
> place in kvm. Let's add an ioctl? Note that qemu doesn't
> need it now ...
>    

We usually expose limits via KVM_CHECK_EXTENSION(KVM_CAP_BLAH).  We can 
expose it via KVM_CAP_IOEVENTFD (and need to reserve iodev entries for 
those).

-- 
error compiling committee.c: too many arguments to function

