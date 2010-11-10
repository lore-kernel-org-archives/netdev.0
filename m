From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v15 00/17] Provide a zero-copy method on KVM virtio-net.
Date: Wed, 10 Nov 2010 09:46:41 -0800 (PST)
Message-ID: <20101110.094641.193701683.davem@davemloft.net>
References: <20101109.091516.112581012.davem@davemloft.net>
	<1289381008-5484-1-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	herbert@gondor.apana.org.au, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1289381008-5484-1-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiaohui.xin@intel.com
Date: Wed, 10 Nov 2010 17:23:28 +0800

> From: Xin Xiaohui <xiaohui.xin@intel.com>
> 
>>2) The idea to key off of skb->dev in skb_release_data() is
>>   fundamentally flawed since many actions can change skb->dev on you,
>>   which will end up causing a leak of your external data areas.
> 
> How about this one? If the destructor_arg is not a good candidate,
> then I have to add an apparent field in shinfo.

If destructor_arg is actually a net_device pointer or similar,
you will need to take a reference count on it or similar.

Which means --> good bye performance especially on SMP.

You're going to be adding new serialization points and at
least two new atomics per packet.
