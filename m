From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 4/4] pci-hyperv: do not sleep in
 compose_msi_msg
Date: Mon, 31 Jul 2017 16:40:38 -0700
Message-ID: <20170731164038.49bc878a@xeon-e3>
References: <20170731233712.12087-1-sthemmin@microsoft.com>
        <20170731233712.12087-5-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        corbet@lwn.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170731233712.12087-5-sthemmin@microsoft.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 31 Jul 2017 16:37:12 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> The setup of MSI with Hyper-V host was sleeping with locks held.
> This error is reported when doing SR-IOV hotplug with kernel built with lockdep.
> 
>     BUG: sleeping function called from invalid context at kernel/sched/completion.c:93
>     in_atomic(): 1, irqs_disabled(): 1, pid: 1405, name: ip
>     3 locks held by ip/1405:
>    #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff976b10bb>] rtnetlink_rcv+0x1b/0x40
>    #1:  (&desc->request_mutex){+.+...}, at: [<ffffffff970ddd33>] __setup_irq+0xb3/0x720
>    #2:  (&irq_desc_lock_class){-.-...}, at: [<ffffffff970ddd65>] __setup_irq+0xe5/0x720
>    irq event stamp: 3476
>    hardirqs last  enabled at (3475): [<ffffffff971b3005>] get_page_from_freelist+0x225/0xc90
>    hardirqs last disabled at (3476): [<ffffffff978024e7>] _raw_spin_lock_irqsave+0x27/0x90
>    softirqs last  enabled at (2446): [<ffffffffc05ef0b0>] ixgbevf_configure+0x380/0x7c0 [ixgbevf]
>    softirqs last disabled at (2444): [<ffffffffc05ef08d>] ixgbevf_configure+0x35d/0x7c0 [ixgbevf]
> 
> The workaround is to poll for host response instead of blocking on
> completion.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

This patch is not directly network related. It needs to go through PCI.

I will resend the series.
