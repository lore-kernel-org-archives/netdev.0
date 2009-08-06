From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 06 Aug 2009 08:06:18 -0600
Message-ID: <4A7AAB1A0200005A00051BED@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <20090806081955.GA9752@redhat.com>
 <4A7A8F7B0200005A00051B84@sinclair.provo.novell.com>
 <4A7AD29E.50800@redhat.com>
 <4A7A9C6B0200005A00051BB9@sinclair.provo.novell.com>
 <4A7ADE23.5010208@redhat.com>
 <4A7AA63A0200005A00051BE2@sinclair.provo.novell.com>
 <4A7AE150.7040009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, <kvm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Avi Kivity" <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A7AE150.7040009@redhat.com>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 8/6/2009 at  9:57 AM, in message <4A7AE150.7040009@redhat.com>, Avi Kivity
<avi@redhat.com> wrote: 
> On 08/06/2009 04:45 PM, Gregory Haskins wrote:
>>
>>> (though still rooting for virtio).
>>>      
>>
>> Heh...not to belabor the point to death, but virtio is orthogonal (you keep 
> forgetting that ;).
>>
>> Its really the vbus device-model vs the qemu device-model (and possibly vs the 
> "in-kernel pci emulation" model that I believe Michael is working on).
>>
>> You can run virtio on any of those three.
>>    
> 
> It's not orthogonal.  virtio is one set of ABI+guest drivers+host 
> support to get networking on kvm guests.  AlacrityVM's vbus-based 
> drivers are another set of ABI+guest drivers+host support to get 
> networking on kvm guests.  That makes them competitors (two different 
> ways to do one thing), not orthogonal.

Thats not accurate, though.

The virtio stack is modular.  For instance, with virtio-net, you have

  (guest-side)
|--------------------------
| virtio-net
|--------------------------
| virtio-ring
|--------------------------
| virtio-bus
|--------------------------
| virtio-pci
|--------------------------
                      |
                   (pci)
                      |
|--------------------------
| kvm.ko
|--------------------------
| qemu
|--------------------------
| tun-tap
|--------------------------
| netif
|--------------------------
     (host-side)

We can exchange out the "virtio-pci" module like this:

  (guest-side)
|--------------------------
| virtio-net
|--------------------------
| virtio-ring
|--------------------------
| virtio-bus
|--------------------------
| virtio-vbus
|--------------------------
| vbus-proxy
|--------------------------
| vbus-connector
|--------------------------
                      |
                   (vbus)
                      |
|--------------------------
| kvm.ko
|--------------------------
| vbus-connector
|--------------------------
| vbus
|--------------------------
| virtio-net-tap (vbus model)
|--------------------------
| netif
|--------------------------
     (host-side)


So virtio-net runs unmodified.  What is "competing" here is "virtio-pci" vs "virtio-vbus".  Also, venet vs virtio-net are technically competing.  But to say "virtio vs vbus" is inaccurate, IMO.

HTH
-Greg

