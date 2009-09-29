From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: Fix sid connector (was: Badness at kernel/softirq.c:143...)
Date: Tue, 29 Sep 2009 21:07:22 +0400
Message-ID: <20090929170722.GA32330@ioremap.net>
References: <200909251123.03482.borntraeger@de.ibm.com> <20090929142538.GA10180@redhat.com> <20090929144554.GA10937@redhat.com> <200909291712.33099.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>,
	Scott James Remnant <scott@ubuntu.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Matt Helsley <matthltc@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:41694 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826AbZI2RHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 13:07:19 -0400
Content-Disposition: inline
In-Reply-To: <200909291712.33099.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2009 at 05:12:33PM +0200, Christian Borntraeger (borntraeger@de.ibm.com) wrote:
> just in case the discussion concludes that my patch is fine,
> here is a fixed version.
> 
> [PATCH] connector: Fix sid connector
> 
> The sid connector gives the following warning:
> Badness at kernel/softirq.c:143
> [...]
> Call Trace:
> ([<000000013fe04100>] 0x13fe04100)
>  [<000000000048a946>] sk_filter+0x9a/0xd0
>  [<000000000049d938>] netlink_broadcast+0x2c0/0x53c
>  [<00000000003ba9ae>] cn_netlink_send+0x272/0x2b0
>  [<00000000003baef0>] proc_sid_connector+0xc4/0xd4
>  [<0000000000142604>] __set_special_pids+0x58/0x90
>  [<0000000000159938>] sys_setsid+0xb4/0xd8
>  [<00000000001187fe>] sysc_noemu+0x10/0x16
>  [<00000041616cb266>] 0x41616cb266
> 
> The warning is
> --->    WARN_ON_ONCE(in_irq() || irqs_disabled());
> 
> The network code must not be called with disabled interrupts but
> sys_setsid holds the tasklist_lock with spinlock_irq while calling
> the connector. We can safely move proc_sid_connector from
> __set_special_pids to sys_setsid.
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

Looks good, thank you.
Ack.

-- 
	Evgeniy Polyakov
