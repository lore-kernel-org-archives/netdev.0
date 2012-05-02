From: Deng-Cheng Zhu <dczhu@mips.com>
Subject: Re: [PATCH] RPS: Sparse connection optimizations
Date: Wed, 2 May 2012 12:16:39 +0800
Message-ID: <4FA0B527.7020400@mips.com>
References: <1335607805-735-1-git-send-email-dczhu@mips.com>	 <1335614156.2900.66.camel@edumazet-glaptop>  <4FA0B337.1070401@mips.com> <1335931968.22133.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <therbert@google.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns0.mips.com ([12.201.5.70]:47355 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003Ab2EBEQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 00:16:48 -0400
In-Reply-To: <1335931968.22133.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2012 12:12 PM, Eric Dumazet wrote:
> On Wed, 2012-05-02 at 12:08 +0800, Deng-Cheng Zhu wrote:
>
>> Unfortunately, on the Malta platform, NIC irqs are not suitable for SMP
>> IRQ affinity -- they are based on XT-PIC. However, I did do some RPS
>> tests where different CPU masks were assigned to the 2 NICs. And the
>> throughput *WAS* better than that of assigning the same mask to NICs.
>> But the problem addressed in this patch *STILL* exists -- hash indexing
>> causes imbalance across CPUs in the case of sparse connections.
>
> You mean your two NIC irqs are handled by CPU0 and this cant be
> changed ?
>
> That really is bad.
>
>
>

Yes, that's right. It's not IO-APIC enabled. When trying to write values
to /proc/irq/$irqnum/smp_affinity:

echo: write error: Input/output error


Deng-Cheng
