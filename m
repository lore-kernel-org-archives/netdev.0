From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: Re: NULL pointer dereference at netxen_nic_probe+0x813/0x9a0
Date: Sat, 30 Oct 2010 23:56:24 +0400
Message-ID: <4CCC7868.60104@kernel.org>
References: <201010281250.50802.bjorn.helgaas@hp.com>	<AANLkTim8coGDmxxCnhzXXLEswf1OYptswbA59BYcbp-N@mail.gmail.com>	<4CCB24CA.3050106@kernel.org> <20101029.125403.71123384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bjorn.helgaas@hp.com, amit.salecha@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101029.125403.71123384.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2010 11:54 PM, David Miller wrote:
> From: Denis Kirjanov <dkirjanov@kernel.org>
> Date: Fri, 29 Oct 2010 23:47:22 +0400
> 
>>> This is on current Linus upstream as of this morning (8128057)
>>> on an HP DL785:
>>>
>>> QLogic/NetXen Network Driver v4.0.74
>>> netxen_nic 0000:07:00.0: PCI INT A -> GSI 30 (level, low) -> IRQ 30
>>> netxen_nic 0000:07:00.0: setting latency timer to 64
>>> netxen_nic 0000:07:00.0: 2MB memory map
>>> netxen_nic 0000:07:00.0: loading firmware from flash
>>> netxen_nic 0000:07:00.0: using 64-bit dma mask
>>> kernel: Quad Gig LP Board S/N TI9ABK0266  Chip rev 0x42
>>> netxen_nic 0000:07:00.0: firmware v4.0.520 [legacy]
>>> netxen_nic 0000:07:00.0: irq 72 for MSI/MSI-X
>>> netxen_nic 0000:07:00.0: irq 73 for MSI/MSI-X
>>> netxen_nic 0000:07:00.0: irq 74 for MSI/MSI-X
>>> netxen_nic 0000:07:00.0: irq 75 for MSI/MSI-X
>>> netxen_nic 0000:07:00.0: using msi-x interrupts
>>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
>>> IP: [<ffffffff8160afda>] netxen_nic_probe+0x813/0x9a0
>>> PGD 0
>>> Oops: 0002 [#1] SMP
>>> last sysfs file:
>>> CPU 0
>>> Modules linked in:
>>>
>>> Pid: 1650, comm: work_for_cpu Not tainted 2.6.36-07338-g8128057 #269
>>> /ProLiant DL785 G5
>>> RIP: 0010:[<ffffffff8160afda>]  [<ffffffff8160afda>]
>>> netxen_nic_probe+0x813/0x9a0
>>> RSP: 0018:ffff8806138abe30  EFLAGS: 00010246
>>> RAX: 0000000000000010 RBX: ffff8806139126c0 RCX: 0000000000000000
>>> RDX: 0000000000000000 RSI: ffff880613895616 RDI: ffff880613912000
>>> RBP: ffff8806138abe90 R08: 0000000000000000 R09: ffff8806138abb80
>>> R10: 0000000000000000 R11: 0000000000000000 R12: ffff880613912000
>>> R13: ffff8812174f7000 R14: ffff880613912000 R15: ffff8812174f7000
>>> FS:  0000000000000000(0000) GS:ffff8800cfa00000(0000) knlGS:0000000000000000
>>> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>> CR2: 0000000000000010 CR3: 0000000001c07000 CR4: 00000000000006f0
>>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>> Process work_for_cpu (pid: 1650, threadinfo ffff8806138aa000, task
>>> ffff880616f12be0)
>>> Stack:
>>>  ffff8812174f7090 0000000000000246 ffff8806138abe90 ffff8812174f7000
>>>  00008806138abfd8 0000000000000282 68cd0025b30068cc ffff880c17439d30
>>>  ffff8812174f7090 ffff8812174f7000 ffff8812174f7208 0000000000000000
>>> Call Trace:
>>>  [<ffffffff81203696>] local_pci_probe+0x48/0x91
>>>  [<ffffffff81052bae>] ? do_work_for_cpu+0x0/0x26
>>>  [<ffffffff81052bc1>] do_work_for_cpu+0x13/0x26
>>>  [<ffffffff81052bae>] ? do_work_for_cpu+0x0/0x26
>>>  [<ffffffff81057a7b>] kthread+0x81/0x89
>>>  [<ffffffff81003854>] kernel_thread_helper+0x4/0x10
>>>  [<ffffffff810579fa>] ? kthread+0x0/0x89
>>>  [<ffffffff81003850>] ? kernel_thread_helper+0x0/0x10
>>> Code: 00 eb 15 49 8d bf 90 00 00 00 48 c7 c6 1b 2e aa 81 31 c0 e8 c0
>>> 4e cd ff 4c 89 f7 e8 d6 bb ee ff 49 8b 96 00 03 00 00 48 8d 42 10 <f0>
>>> 80 4a 10 01 4c 89 f7 e8 a3 7e ed ff 85 c0 41 89 c4 74 2a 49
>>> RIP  [<ffffffff8160afda>] netxen_nic_probe+0x813/0x9a0
>>>  RSP <ffff8806138abe30>
>>> CR2: 0000000000000010
>>> ---[ end trace 059c7071bbf8de1f ]---
>> Could you please try the following patch.  
> 
> Why do you need to touch the queue state at all in the probing code?
> 
> Until the first ->open() occurs, the queue state is "don't care."
> 
> The netif_carrier_off() call is fine.
> 
Ok, thanks Dave, now I see.

[PATCH] netxen_nic: Fix the tx queue manipulation bug in netxen_nic_probe

We should not stop the egress queue during probe because it is wrong.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/netxen/netxen_nic_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 50820be..bc156b0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1240,7 +1240,6 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
 
 	err = register_netdev(netdev);
 	if (err) {
-- 
1.7.0
