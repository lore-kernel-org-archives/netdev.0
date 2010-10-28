From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Thu, 28 Oct 2010 10:14:22 -0700
Message-ID: <1288286062.11251.15.camel@localhost.localdomain>
References: <1288216693.17571.38.camel@localhost.localdomain>
	 <1288240804.14342.1.camel@localhost.localdomain>
	 <20101028052021.GD5599@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101028052021.GD5599@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Two ideas:
> 1. How about writing out used, just delaying the signal?
>    This way we don't have to queue separately.

This improves some performance, but not as good as delaying
both used and signal. Since delaying used buffers combining
multiple small copies to a large copy, which saves more CPU
utilization and increased some BW.

> 2. How about flushing out queued stuff before we exit
>    the handle_tx loop? That would address most of
>    the spec issue. 

The performance is almost as same as the previous patch. I will resubmit
the modified one, adding vhost_add_used_and_signal_n after handle_tx
loop for processing pending queue.

This patch was a part of modified macvtap zero copy which I haven't
submitted yet. I found this helped vhost TX in general. This pending
queue will be used by DMA done later, so I put it in vq instead of a
local variable in handle_tx.

Thanks
Shirley

