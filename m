From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Date: Mon, 31 Aug 2009 20:52:02 +0300
Message-ID: <4A9C0DC2.6080704@redhat.com>
References: <E88DD564E9DC5446A76B2B47C3BCCA150219600F9B@pdsmsx503.ccr.corp.intel.com> <C85CEDA13AB1CF4D9D597824A86D2B9006AEB944B8@PDSMSX501.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "mst@redhat.com" <mst@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>,
        "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mingo@elte.hu" <mingo@elte.hu>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "hpa@zytor.com" <hpa@zytor.com>,
        "gregory.haskins@gmail.com" <gregory.haskins@gmail.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB944B8@PDSMSX501.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 08/31/2009 02:42 PM, Xin, Xiaohui wrote:
> Hi, Michael
> That's a great job. We are now working on support VMDq on KVM, and since the VMDq hardware presents L2 sorting based on MAC addresses and VLAN tags, our target is to implement a zero copy solution using VMDq. We stared from the virtio-net architecture. What we want to proposal is to use AIO combined with direct I/O:
> 1) Modify virtio-net Backend service in Qemu to submit aio requests composed from virtqueue.
> 2) Modify TUN/TAP device to support aio operations and the user space buffer directly mapping into the host kernel.
> 3) Let a TUN/TAP device binds to single rx/tx queue from the NIC.
> 4) Modify the net_dev and skb structure to permit allocated skb to use user space directly mapped payload buffer address rather then kernel allocated.
>
> As zero copy is also your goal, we are interested in what's in your mind, and would like to collaborate with you if possible.
>    

One way to share the effort is to make vmdq queues available as normal 
kernel interfaces.  It would take quite a bit of work, but the end 
result is that no other components need to be change, and it makes vmdq 
useful outside kvm.  It also greatly reduces the amount of integration 
work needed throughout the stack (kvm/qemu/libvirt).

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
