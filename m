From: Reuben Farrelly <reuben-linux@reub.net>
Subject: Re: Kernel crash in 2.6.0-test9-mm3
Date: Wed, 19 Nov 2003 15:58:18 +1300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6.0.1.1.0.20031119155347.023f89d0@tornado.reub.net>
References: <OF0696EDA9.D66EB77E-ON88256DE3.0009C15A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <OF0696EDA9.D66EB77E-ON88256DE3.0009C15A@us.ibm.com>
References: <OF0696EDA9.D66EB77E-ON88256DE3.0009C15A@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The system is a UP system..

# CONFIG_SMP is not set
CONFIG_PREEMPT=y
CONFIG_X86_UP_APIC=y
CONFIG_X86_UP_IOAPIC=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_TSC=y
CONFIG_X86_MCE=y

I've put the full .config up at http://www.reub.net/linux/

Reuben



At 15:22 19/11/2003, Krishna Kumar wrote:
>Could this be happening on an SMP system only ? If so, e100intr routine
>services tx queues (e100_tx_srv)
>without holding a lock. Can't multiple rx interrupts be scheduled on
>different cpus at the same time, and
>each execute dev_kfree_skb_irq() which decrements the ref count too many
>times ? But the softirq handler
>(net_tx_action) seems to clean up the skb once as the dec_test returns 1
>only if count is zero, so I don't see
>where the dst ref is being decremented wrongly in this case.
