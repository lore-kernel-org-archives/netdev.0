From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Date: Mon, 31 Aug 2009 16:56:51 -0500
Message-ID: <4A9C4723.5080309@codemonkey.ws>
References: <E88DD564E9DC5446A76B2B47C3BCCA150219600F9B@pdsmsx503.ccr.corp.intel.com> <C85CEDA13AB1CF4D9D597824A86D2B9006AEB944B8@PDSMSX501.ccr.corp.intel.com> <4A9C0DC2.6080704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
 "mst@redhat.com" <mst@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>,
 "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "mingo@elte.hu" <mingo@elte.hu>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "hpa@zytor.com" <hpa@zytor.com>,
 "gregory.haskins@gmail.com" <gregory.haskins@gmail.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4A9C0DC2.6080704@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Avi Kivity wrote:
> On 08/31/2009 02:42 PM, Xin, Xiaohui wrote:
>> Hi, Michael
>> That's a great job. We are now working on support VMDq on KVM, and 
>> since the VMDq hardware presents L2 sorting based on MAC addresses 
>> and VLAN tags, our target is to implement a zero copy solution using 
>> VMDq. We stared from the virtio-net architecture. What we want to 
>> proposal is to use AIO combined with direct I/O:
>> 1) Modify virtio-net Backend service in Qemu to submit aio requests 
>> composed from virtqueue.
>> 2) Modify TUN/TAP device to support aio operations and the user space 
>> buffer directly mapping into the host kernel.
>> 3) Let a TUN/TAP device binds to single rx/tx queue from the NIC.
>> 4) Modify the net_dev and skb structure to permit allocated skb to 
>> use user space directly mapped payload buffer address rather then 
>> kernel allocated.
>>
>> As zero copy is also your goal, we are interested in what's in your 
>> mind, and would like to collaborate with you if possible.
>>    
>
> One way to share the effort is to make vmdq queues available as normal 
> kernel interfaces.

It may be possible to make vmdq appear like an sr-iov capable device 
from userspace.  sr-iov provides the userspace interfaces to allocate 
interfaces and assign mac addresses.  To make it useful, you would have 
to handle tx multiplexing in the driver but that would be much easier to 
consume for kvm.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
