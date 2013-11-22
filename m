From: Alexander Graf <agraf@suse.de>
Subject: gem csum breakage with 018c5bba (Handle CHECKSUM_COMPLETE more adequately ...)
Date: Fri, 22 Nov 2013 19:08:16 +0100
Message-ID: <B8BCE323-6F65-4D14-BD4A-BFA07C3ED290@suse.de>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: herbert@gondor.apana.org.au, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, edumazet@google.com,
	herbert@gondor.apana.org,
	"linux-kernel@vger.kernel.org list" <linux-kernel@vger.kernel.org>,
	Ben Herrenschmidt <benh@kernel.crashing.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

With current Linus' master tree my ibook started emitting a lot of annoying csum calculation warnings. I've bisected it down to the commit seen in the subject line, but I suppose the real problem lies somewhere a lot deeper and only gets revealed thanks to the more clever checksum logic applied now.

Any ideas how to dig further into this?


Thanks,

Alex

---

<unknown>: hw csum failure
CPU: 0 PID: 0 Comm: swapper Not tainted 3.12.0+ #1
Call Trace:
[efff1d00] [c00090f0] show_stack+0x48/0x150 (unreliable)
[efff1d40] [c049f794] csum_partial_copy_to_xdr+0xf8/0x168
[efff1d60] [c04a1120] xs_udp_data_ready+0xbc/0x140
[efff1d90] [c03f99f4] sock_queue_rcv_skb+0x144/0x1c0
[efff1db0] [c045aa28] __udp_queue_rcv_skb+0x38/0xd4
[efff1dc0] [c045de5c] udp_queue_rcv_skb+0x260/0x3ac
[efff1de0] [c045e6dc] __udp4_lib_rcv+0x2c8/0x63c
[efff1e20] [c0432a78] ip_local_deliver_finish+0x100/0x268
[efff1e40] [c0408264] __netif_receive_skb_core+0x510/0x690
[efff1ea0] [c040b78c] napi_gro_receive+0xac/0xd8
[efff1eb0] [c0353b94] gem_poll+0x5bc/0x116c
[efff1f50] [c040a60c] net_rx_action+0x118/0x1fc
[efff1f90] [c0046afc] __do_softirq+0xd4/0x1c4
[efff1fe0] [c0046f04] irq_exit+0x94/0xb8
[efff1ff0] [c000ef30] call_do_irq+0x24/0x3c
[c0733e90] [c0006ca4] do_IRQ+0x64/0xb4
[c0733eb0] [c0011b34] ret_from_except+0x0/0x1c
--- Exception: 501 at arch_cpu_idle+0x24/0x6c
    LR = arch_cpu_idle+0x24/0x6c
[c0733f70] [c0082638] rcu_idle_enter+0x84/0xc4 (unreliable)
[c0733f80] [c007c4b0] cpu_startup_entry+0xa4/0x16c
[c0733fb0] [c06caf54] start_kernel+0x308/0x31c
[c0733ff0] [00003d34] 0x3d34