From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 4/4] bgmac: fix DMA rx corruption
Date: Sun, 12 Apr 2015 19:28:48 +0200
Message-ID: <552AAB50.7010401@openwrt.org>
References: <1428833292-15356-1-git-send-email-nbd@openwrt.org>	 <1428833292-15356-4-git-send-email-nbd@openwrt.org>	 <1428834675.25985.344.camel@edumazet-glaptop2.roam.corp.google.com>	 <552A4C6C.7020802@openwrt.org> <1428859488.25985.347.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:35078 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751489AbbDLR25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Apr 2015 13:28:57 -0400
In-Reply-To: <1428859488.25985.347.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-12 19:24, Eric Dumazet wrote:
> On Sun, 2015-04-12 at 12:43 +0200, Felix Fietkau wrote:
>> On 2015-04-12 12:31, Eric Dumazet wrote:
> 
>> > This might be better for performance to perform one single bgmac_write()
>> > at the end of bgmac_dma_rx_read(), and leave this one in place as well,
>> > not for performance since this is slow path, but correctness.
>> I intentionally made it write this field for every slot update, because
>> it might potentially allow the hardware to push frames faster when under
>> pressure. The CPU isn't fast enough to handle gigabit speeds anyway.
> 
> If CPU is not fast enough, then it makes sense to optimize this part,
> and save cpu cycles for actual processing.
> 
> You know, even a fast cpu is not able to keep up at 40Gbits.
> 
> You have a clear opportunity to have batching right there, take it.
Already did that in v2. :)

- Felix
