From: Diego Viola <diego.viola@gmail.com>
Subject: Computer fails to resume from suspend unless I rmmod jme before
 initiating the suspend
Date: Wed, 10 Feb 2016 02:19:49 -0200
Message-ID: <CA+ToGPGC8APhN-_F5fzyR4CWqWgZ9Hs0PNqykhEgEV7g3PJjTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cooldavid@cooldavid.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guo,

I have an x86 computer with this network card:

02:00.0 Ethernet controller: JMicron Technology Corp. JMC260 PCI
Express Fast Ethernet Controller (rev 03)

Every time I initiate a suspend (systemctl suspend) the machine hangs
at resume unless I unload the jme driver.

Here is a Call Trace I was able to get after it hanged:

<IRQ>
tasklet_action+0xb0/0xd0
__do_softirq+0xcf/0x290
irq_exit+0xa3/0xb0
do_IRQ+0x54/0xd0
common_interrupt+0x82/0x82

<EOI>
jme_start_irq+0x84/0xa0 [jme]
jme_resume+0x12f/0x210 [jme]
pci_pm_resume+0x64/0xa0
? pci_pm_thaw+0x90/0x90
dpm_run_callback+0x4e/0x130
device_resume+0xd3/0x1f0
async_resume+0x1d/0x50
async_run_entry_fn+0x48/0x150
process_one_work+0x14b/0x440
worker_thread+0x48/0x4a0
? process_one_work+0x440/0x440
kthread+0xd8/0xf0
? kthread_worker_fn+0x170/0x170
ret_from_fork+0x3f/0x70
? kthread_worker_fn+0x170/0x170

Please note that I had to type the calltrace above as I don't have a
serial cable and netconsole didn't work for me for some reason, so
there could be typos I didn't notice.

I run Arch Linux (x86-64), my uname is:

$ uname -a
Linux myhost 4.4.1-2-ARCH #1 SMP PREEMPT Wed Feb 3 13:12:33 UTC 2016
x86_64 GNU/Linux

Please let me know if you have any questions or need any other information.

Thanks,

Diego
