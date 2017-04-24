From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 2/2] ixgbe: add support for XDP_TX action
Date: Mon, 24 Apr 2017 12:35:04 -0700
Message-ID: <58FE5368.1000201@gmail.com>
References: <20170424013004.8354.34893.stgit@john-Precision-Tower-5810>
 <20170424013135.8354.93583.stgit@john-Precision-Tower-5810>
 <20170424212921.36fdfff7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36158 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934378AbdDXTfO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:35:14 -0400
Received: by mail-pg0-f65.google.com with SMTP id 34so6550834pgx.3
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 12:35:14 -0700 (PDT)
In-Reply-To: <20170424212921.36fdfff7@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 12:29 PM, Jesper Dangaard Brouer wrote:
> On Sun, 23 Apr 2017 18:31:36 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> +static int ixgbe_xmit_xdp_ring(struct ixgbe_adapter *adapter,
>> +			       struct xdp_buff *xdp)
>> +{
>> +	struct ixgbe_ring *ring = adapter->xdp_ring[smp_processor_id()];
> 
> I was about to question whether is it always true that the array size
> can match the number of CPUs in the system, but I can see later in
> ixgbe_xdp_setup() that you reject XDP program if the system have more
> CPUs that MAX_XDP_QUEUES.

Yep.

[...]

>> +
>> +	tx_buffer->next_to_watch = tx_desc;
>> +	ring->next_to_use = i;
>> +
>> +	writel(i, ring->tail);
> 
> A tailptr write for every XDP_TX packet is not going be fast, but you
> already mentioned that this is not optimal yet, so I guess you are aware.
> 

There is another patch on Jeff's tree to only kick the tail ptr once per
receive path invocation.

https://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git/commit/?h=dev-queue&id=24043a662d11e048de903e12bf86059844c207e2

That patch brings packet rates up to near line rate @ 64 bytes.

Thanks,
John
