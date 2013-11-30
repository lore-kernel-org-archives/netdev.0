From: Christian Kujau <lists@nerdbynature.de>
Subject: 3.13-rc1: eth0 hw csum failure on powerpc
Date: Sat, 30 Nov 2013 02:07:04 -0800 (PST)
Message-ID: <alpine.DEB.2.11.1311300156380.31521@trent.utfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Hi,

while trying to upgrade from 3.12.0 to 3.13-rc1 or -rc2, the following 
happens early during bootup:

[...]
 Freeing unused kernel memory: 204K (c06ea000 - c071d000)
 eth0: hw csum failure
 CPU: 0 PID: 0 Comm: swapper Not tainted 3.13.0-rc2 #1
 Call Trace:
 [effefd00] [c0008b3c] show_stack+0x48/0x150 (unreliable)
 [effefd40] [c045c6ac] __skb_checksum_complete_head+0x7c/0x80
 [effefd50] [c04fefd8] icmpv6_rcv+0x1cc/0x62c
 [effefdf0] [c04e3dd4] ip6_input+0x140/0x4b4
 [effefe30] [c04e422c] ip6_mc_input+0xe4/0x19c
 [effefe40] [c046254c] __netif_receive_skb_core+0x5c4/0x760
 [effefea0] [c04654a0] napi_gro_receive+0xac/0xd8
 [effefeb0] [c03da7e8] gem_poll+0x5bc/0x119c
 [effeff50] [c0465140] net_rx_action+0x150/0x24c
 [effeff90] [c003533c] __do_softirq+0xe8/0x1e8
 [effeffe0] [c003586c] irq_exit+0xa4/0xc8
 [effefff0] [c000e678] call_do_irq+0x24/0x3c
 [c0753e90] [c0006448] do_IRQ+0x64/0xb4
 [c0753eb0] [c0010fac] ret_from_except+0x0/0x14
 --- Exception: 501 at arch_cpu_idle+0x24/0x94
     LR = arch_cpu_idle+0x24/0x94
 [c0753f70] [c0073440] rcu_idle_enter+0x90/0xdc (unreliable)
 [c0753f80] [c006d05c] cpu_startup_entry+0xa8/0x178
 [c0753fb0] [c06ece70] start_kernel+0x2f0/0x304
 [c0753ff0] [00003444] 0x3444


This happens only first right after "Freeing unused kernel...", then 
bootup continues....until a certain point, where these messages are 
repated really often, like 10 times at once, every 5 seconds.

Bootup continues though and I'm even able to login remotely via SSH,
but the messages are really annoying. In 3.13-rc1, the system
rebooted itself shortly after bootup was complete, probably due to
these "eth0: hw csum failure" messages, I assume.

Any ideas on that?

Thanks,
Christian.
-- 
BOFH excuse #16:

somebody was calculating pi on the server
