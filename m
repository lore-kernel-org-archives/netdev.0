From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v9 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Fri, 3 Sep 2010 13:14:37 +0300
Message-ID: <20100903101437.GA31575@redhat.com>
References: <1281086624-5765-1-git-send-email-xiaohui.xin@intel.com>
 <1281489804.3391.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755154Ab0ICKUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 06:20:49 -0400
Content-Disposition: inline
In-Reply-To: <1281489804.3391.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 06:23:24PM -0700, Shirley Ma wrote:
> Hello Xiaohui,
> 
> On Fri, 2010-08-06 at 17:23 +0800, xiaohui.xin@intel.com wrote:
> > Our goal is to improve the bandwidth and reduce the CPU usage.
> > Exact performance data will be provided later. 
> 
> Have you had any performance data to share here? I tested my
> experimental macvtap zero copy for TX only. The performance I have seen
> as below without any tuning, (default setting):
> 
> Before: netperf 16K message size results with 60 secs run is 7.5Gb/s
> over ixgbe 10GbE card. perf top shows:
> 
> 2103.00 12.9% copy_user_generic_string
> 1541.00  9.4% handle_tx
> 1490.00  9.1% _raw_spin_unlock_irqrestore
> 1361.00  8.3% _raw_spin_lock_irqsave
> 1288.00  7.9% _raw_spin_lock
> 924.00  5.7% vhost_worker
> 
> After: netperf results with 60 secs run is 8.1Gb/s, perf output:
> 
> 1093.00  9.9% _raw_spin_unlock_irqrestore
> 1048.00  9.5% handle_tx
> 934.00  8.5% _raw_spin_lock_irqsave
> 864.00  7.9% _raw_spin_lock
> 644.00  5.9% vhost_worker
> 387.00  3.5% use_mm 
> 
> I am still working on collecting more data (latency, cpu
> utilization...). I will let you know once I get all data for macvtap TX
> zero copy. Also I found some vhost performance regression on the new
> kernel with tuning. I used to get 9.4Gb/s, now I couldn't get it.
> 
> Shirley

Could you please try disabling mergeable buffers, and see if this gets
you back where you were?
-global virtio-net-pci.mrg_rxbuf=off 

-- 
MST
