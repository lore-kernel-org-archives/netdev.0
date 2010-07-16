From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/2] bnx2: allocate with GFP_KERNEL flag on RX path init
Date: Fri, 16 Jul 2010 09:13:34 +0200
Message-ID: <20100716091334.268a3f0a@dhcp-lab-109.englab.brq.redhat.com>
References: <20100715142537.12504.60051.send-patch@dhcp-lab-109.englab.brq.redhat.com>
	<C27F8246C663564A84BB7AB3439772421B842BD26F@IRVEXCHCCR01.corp.ad.broadcom.com>
	<20100715.202537.116398412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65267 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935714Ab0GPHNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jul 2010 03:13:46 -0400
In-Reply-To: <20100715.202537.116398412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jul 2010 20:25:37 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> > This should be GFP_ATOMIC since it is called from NAPI softirq
> > context.
> 
> This fatal issue gives me doubts about whether this patch was even
> tested at all.
> 
> Immediately the kernel memory allocator should have issued a warning
> due to this GFP_KERNEL allocation in a non-sleep'able context.
> 
> Stanislaw, how did you test this patch?

I run net-next-2.6 kernel with patches on machine with bnx2 device,
but I compiled kernel with CONFIG_DEBUG_KOBJECT and all dmesg was filled
by messages like:

kobject: 'block' (ffff8801663122c0): kobject_add_internal: parent: '2:2:1:0', set: '(null)'
kobject: 'sdc' (ffff8801642ca070): kobject_add_internal: parent: 'block', set: 'devices'
kobject: 'sdc' (ffff8801642ca070): kobject_uevent_env

so I missed the warning, grr...

Stanislaw
