From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][PATCH v4 00/18] Provide a zero-copy method on KVM
	virtio-net.
Date: Sun, 25 Apr 2010 13:46:04 +0300
Message-ID: <20100425104604.GA10238@redhat.com>
References: <1272187206-18534-17-git-send-email-xiaohui.xin@intel.com> <1272187206-18534-18-git-send-email-xiaohui.xin@intel.com> <1272187206-18534-19-git-send-email-xiaohui.xin@intel.com> <20100425.025529.123989625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, jdike@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24620 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752718Ab0DYKt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Apr 2010 06:49:57 -0400
Content-Disposition: inline
In-Reply-To: <20100425.025529.123989625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 02:55:29AM -0700, David Miller wrote:
> From: xiaohui.xin@intel.com
> Date: Sun, 25 Apr 2010 17:20:06 +0800
> 
> > The idea is simple, just to pin the guest VM user space and then let
> > host NIC driver has the chance to directly DMA to it.
> 
> Isn't it much easier to map the RX ring of the network device into the
> guest's address space, have DMA map calls translate guest addresses to
> physical/DMA addresses as well as do all of this crazy page pinning
> stuff, and provide the translations and protections via the IOMMU?

This means we need guest know how the specific network device works.
So we won't be able to, for example, move guest between different hosts.
There are other problems: many physical systems do not have an iommu,
some guest OS-es do not support DMA map calls, doing VM exit
on each DMA map call might turn out to be very slow. And so on.

> What's being proposed here looks a bit over-engineered.

This is an attempt to reduce overhead for virtio (paravirtualization).
'Don't use PV' is kind of an alternative, but I do not
think it's a simpler one.

-- 
MST
