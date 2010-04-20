From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC][PATCH v2 0/3] Provide a zero-copy method on KVM
	virtio-net.
Date: Tue, 20 Apr 2010 10:21:55 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D79026FAB1E5F@shsmsx502.ccr.corp.intel.com>
References: <1270193100-6769-1-git-send-email-xiaohui.xin@intel.com>
 <20100414152519.GA10792@redhat.com>
 <97F6D3BD476C464182C1B7BABF0B0AF5C18969CC@shzsmsx502.ccr.corp.intel.com>
 <20100415100546.GA17035@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D79026FA95401@shsmsx502.ccr.corp.intel.com>
 <20100419102118.GA16198@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100419102118.GA16198@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,

>>>>>> What we have not done yet:
>>>>>> 	packet split support
>>>>>> 
>>>>>What does this mean, exactly?
>>>> We can support 1500MTU, but for jumbo frame, since vhost driver before don't 
>>>>support mergeable buffer, we cannot try it for multiple sg.
>>>> 
>>>I do not see why, vhost currently supports 64K buffers with indirect
>>>descriptors.
>>> 
>> The receive_skb() in guest virtio-net driver will merge the multiple sg to skb frags, how >>can indirect descriptors to that?

>See add_recvbuf_big.

I don't mean this, it's for buffer submission. I mean when packet is received, in receive_buf(), mergeable buffer knows which pages received can be hooked in skb frags, it's receive_mergeable() which do this.

When a NIC driver supports packet split mode, then each ring descriptor contains a skb and a page. When packet is received, if the status is not EOP, then hook the page of the next descriptor to the prev skb. We don't how many frags belongs to one skb. So when guest submit buffers, it should submit multiple pages, and when receive, the guest should know which pages are belongs to one skb and hook them together. I think receive_mergeable() can do this, but I don't see how big->packets handle this. May I miss something here?

Thanks
Xiaohui 
