From: "Michael Chan" <mchan@broadcom.com>
Subject: suspend/resume not working in MSIX mode
Date: Mon, 14 Jun 2010 18:13:22 -0700
Message-ID: <1276564403.19104.28.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm debugging the bnx2 driver which doesn't work after suspend/resume if
it is running in MSI-X mode.  The problem is that during suspend, the
MSI-X vectors are disabled by the following sequence on x86:

take_cpu_down() -> cpu_disable_common() -> fixup_irqs()

The MSI-X address/data used to disable the vectors are remembered in the
above sequence.  During resume, these address/data are then programmed
back to the device during pci_restore_state(), causing all the vectors
to remain disabled.

Some drivers call free_irq() during suspend and request_irq() during
resume, and that should avoid the problem.  bnx2 and some other drivers
do not do that.  These drivers rely on pci_restore_state() to restore
the MSI-X vectors to the same working state before suspend.

What's the right way to fix this?  Thanks.
