From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v15 00/17] Provide a zero-copy method on KVM virtio-net.
Date: Tue, 09 Nov 2010 09:15:16 -0800 (PST)
Message-ID: <20101109.091516.112581012.davem@davemloft.net>
References: <1289293402-4791-1-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	herbert@gondor.apana.org.au, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47093
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751792Ab0KIROw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 12:14:52 -0500
In-Reply-To: <1289293402-4791-1-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: xiaohui.xin@intel.com
Date: Tue,  9 Nov 2010 17:03:05 +0800

> We provide an zero-copy method which driver side may get external
> buffers to DMA. Here external means driver don't use kernel space
> to allocate skb buffers. Currently the external buffer can be from
> guest virtio-net driver.

1) Please use kernel-doc style comments to document structure
   members.

2) The idea to key off of skb->dev in skb_release_data() is
   fundamentally flawed since many actions can change skb->dev on you,
   which will end up causing a leak of your external data areas.
