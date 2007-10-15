From: "Chris Friesen" <cfriesen@nortel.com>
Subject: question on sky2 driver panic
Date: Mon, 15 Oct 2007 14:17:50 -0600
Message-ID: <4713CAEE.6010106@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:34507 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765923AbXJOUSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 16:18:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

We're using Yukon-XL (0xb3) rev 3 hardware with a vendor-supplied 
2.6.14.  BAsed on suggestions here, I backported the sky2 driver (v1.10 
from 2.6.20.6) to 2.6.14.

Unfortunately, when I booted this I got the following:


skb_over_panic: text:d0000000000d4e14 len:60 put:60 
head:c000000264920770 data:c000000264920720 tail:c000000264920720 
end:c0000002649207a0 dev:<NULL>
kernel BUG in skb_over_panic at 
/usr/local/src/2.6.14/gd/linux/net/core/skbuff.c:94!
Oops: Exception in kernel mode, sig: 5 [#1]
SMP NR_CPUS=2
Modules linked in: tipc bond1 bond0 ipmi_devintf ipmi_msghandler
NIP: C00000000020D7E8 XER: 00000000 LR: C00000000020D7E4 CTR: 
C0000000001C210C
REGS: c00000025c2aefe0 TRAP: 0700   Not tainted  (2.6.14-pne)
MSR: 9000000000029032 EE: 1 PR: 0 FP: 0 ME: 1 IR/DR: 11 CR: 28008022
DAR: 0000000000000000 DSISR: c00000025c2af1c0
TASK: c00000000fec2940[2107] 'insmod' THREAD: c00000025c2ac000 CPU: 0
GPR00: C00000000020D7E4 C00000025C2AF300 C00000000041DA08 000000000000009C
GPR04: 9000000000009032 FFFFFFFFFFFFFFFF 0000000000000030 C00000000037C428
GPR08: 0000000000000000 C00000000037EEF0 C00000000043AD68 C00000000043AC88
GPR12: 0000000000000010 C000000000374000 0000000000000000 00000000100D47E8
GPR16: 00000000100D55A0 00000000FFFFFFFF 00000000FFFFFFFF 0000000000000000
GPR20: 0000000000000000 0000000000000000 0000000000000000 0000000000000001
GPR24: 0000000000000000 00000000B6AA7FFF 0000000000000000 0000000000000000
GPR28: 000000000000003C C00000000FEF5B10 C0000000003BB778 000000000000003C
NIP [c00000000020d7e8] .skb_over_panic+0x50/0x68
LR [c00000000020d7e4] .skb_over_panic+0x4c/0x68
Call Trace:
[c00000025c2af300] [c00000000020d7e4] .skb_over_panic+0x4c/0x68 (unreliable)
[c00000025c2af390] [d0000000000d4e20] .named_prepare_buf+0x298/0x2a8 [tipc]
[c00000025c2af450] [d0000000000d4e90] .named_publish+0x60/0xe4 [tipc]
[c00000025c2af4e0] [d0000000000d80a8] .nametbl_publish+0x128/0x198 [tipc]
[c00000025c2af590] [d0000000000de7dc] .tipc_publish+0xe8/0x188 [tipc]
[c00000025c2af650] [d0000000000d7f4c] .nametbl_publish_rsv+0x30/0x64 [tipc]
[c00000025c2af6e0] [d0000000000d2600] .cfg_init+0x120/0x150 [tipc]
[c00000025c2af7a0] [d0000000000e31ac] .process_signal_queue+0xa4/0x100 
[tipc]
[c00000025c2af8/0x1ec [tipc]
[c00000025c2afcf0] [c0000000000685ec] .sys_init_module+0x28c/0x510
[c00000025c2afd90] [c000000000009b9c] syscall_exit+0x0/0x18



Now granted it looks like this was triggered by tipc, but is there 
anything that you can think of in the sky2 driver that may have been 
related?  Maybe due to the fragmented buffer handling?  The link would 
have been using an mtu of 9KB.

Thanks,

Chris
