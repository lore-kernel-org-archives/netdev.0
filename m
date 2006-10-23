From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-softmac: add PCI-E code
Date: Mon, 23 Oct 2006 09:22:16 -0400
Message-ID: <453CC208.8010102@gentoo.org>
References: <45330803.mail261110C22@lwfinger.net>
	<200610201855.21183.mb@bu3sch.de> <453914AE.2090604@gentoo.org>
	<200610202037.47758.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <200610202037.47758.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Please try 2.6.18.1 or wireless-2.6.
> 


2.6.18.1 (with the PCI-E patch) crashes on modprobe:

bcm43xx driver
ACPI: PCI Interrupt Link [LK1E] enabled at IRQ 11
ACPI: PCI Interrupt 0000:03:00.0[A] -> Link [LK1E] -> GSI 11 (level, 
low) -> IRQ 11
PCI: Setting latency timer of device 0000:03:00.0 to 64
bcm43xx: Could not determine Chip ID
Unable to handle kernel NULL pointer dereference at 0000000000000001 RIP:
  [<ffffffff8802625a>] :bcm43xx:bcm43xx_pctl_set_crystal+0x121/0x1a5
PGD 7ae20067 PUD 7d606067 PMD 0
Oops: 0000 [1] SMP
CPU 0
Modules linked in: bcm43xx ieee80211softmac ieee80211 ieee80211_crypt
Pid: 6018, comm: modprobe Not tainted 2.6.181 #1
RIP: 0010:[<ffffffff8802625a>]  [<ffffffff8802625a>] 
:bcm43xx:bcm43xx_pctl_set_crystal+0x121/0x1a5
RSP: 0000:ffff8100779cfd08  EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff810002efefc0
RDX: ffffc20000380000 RSI: 0000000000000246 RDI: ffffffff804ed780
RBP: ffff8100783d1178 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000080 R12: 0000000000000000
R13: ffff8100783d0000 R14: 0000000042439001 R15: 0000000000000900
FS:  00002ae4eb4c7ae0(0000) GS:ffffffff8059e000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000001 CR3: 00000000788a9000 CR4: 00000000000006e0
Process modprobe (pid: 6018, threadinfo ffff8100779ce000, task 
ffff81007d0062c0)
Stack:  000000c0783d1178 0000000000000000 00000000ffffffed ffff8100783d1178
  0000000000004710 ffffffff880175d6 ffff8100779cfd78 ffffffff80229f8e
  ffff810002fd7800 ffff81007de314c0 ffffffff80515fa0 0000000000000246
Call Trace:
  [<ffffffff880175d6>] :bcm43xx:bcm43xx_attach_board+0x120f/0x1284
  [<ffffffff80229f8e>] __wake_up+0x38/0x4f
  [<ffffffff80240a48>] __queue_work+0x4e/0x5e
  [<ffffffff80240ad6>] queue_work+0x4e/0x58
  [<ffffffff88018d5f>] :bcm43xx:bcm43xx_init_one+0x222/0x270
  [<ffffffff8030ba3e>] pci_device_probe+0x4c/0x75
  [<ffffffff8035b828>] driver_probe_device+0x52/0xa8
  [<ffffffff8035b957>] __driver_attach+0x6d/0xaa
  [<ffffffff8035b8ea>] __driver_attach+0x0/0xaa
  [<ffffffff8035b229>] bus_for_each_dev+0x43/0x6e
  [<ffffffff8035ae87>] bus_add_driver+0x7e/0x130
  [<ffffffff8030bbd9>] __pci_register_driver+0x57/0x7d
  [<ffffffff8024c9a9>] sys_init_module+0xab/0x1ae
  [<ffffffff802098ce>] system_call+0x7e/0x83
