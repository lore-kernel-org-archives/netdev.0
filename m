From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v11 00/17] Provide a zero-copy method on KVM virtio-net.
Date: Mon, 27 Sep 2010 08:44:52 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D792EC64F74FA@shsmsx502.ccr.corp.intel.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
 <20100926170142.GA24196@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100926170142.GA24196@redhat.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: Michael S. Tsirkin [mailto:mst@redhat.com]
>Sent: Monday, September 27, 2010 1:02 AM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>jdike@linux.intel.com
>Subject: Re: [PATCH v11 00/17] Provide a zero-copy method on KVM virtio-net.
>
>On Sat, Sep 25, 2010 at 12:27:18PM +0800, xiaohui.xin@intel.com wrote:
>> We provide an zero-copy method which driver side may get external
>> buffers to DMA. Here external means driver don't use kernel space
>> to allocate skb buffers. Currently the external buffer can be from
>> guest virtio-net driver.
>>
>> The idea is simple, just to pin the guest VM user space and then
>> let host NIC driver has the chance to directly DMA to it.
>> The patches are based on vhost-net backend driver. We add a device
>> which provides proto_ops as sendmsg/recvmsg to vhost-net to
>> send/recv directly to/from the NIC driver. KVM guest who use the
>> vhost-net backend may bind any ethX interface in the host side to
>> get copyless data transfer thru guest virtio-net frontend.
>> patch 01-10:  	net core and kernel changes.
>> patch 11-13:  	new device as interface to mantpulate external buffers.
>> patch 14: 	for vhost-net.
>> patch 15:	An example on modifying NIC driver to using napi_gro_frags().
>> patch 16:	An example how to get guest buffers based on driver
>> 		who using napi_gro_frags().
>> patch 17:	It's a patch to address comments from Michael S. Thirkin
>> 		to add 2 new ioctls in mp device.
>> 		We split it out here to make easier reiewer.
>
>
>
>I commented on how to avoid mm semaphore on data path separately, and
>since you didn't have time to review that yet, I won't repeat that here.
>

I think I did avoid that in data path to use mm semaphore. I stored the value
in mp structures and check with that.

>At this point what are the plans on macvtap integration?
>You indicated this is the interface you intend to use longterm.

I'm now working on that.


Thanks
Xiaohui
