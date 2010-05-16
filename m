From: Krzysztof Oledzki <ole@ans.pl>
Subject: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Sun, 16 May 2010 15:33:03 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.1005161511490.6004@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-573665055-1274016784=:6004"
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:51848 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179Ab0EPNvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 09:51:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-573665055-1274016784=:6004
Content-Type: TEXT/PLAIN; format=flowed; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT

Hello,

I have a Dell R610 server with BCM5709 NICs. The server has one, 4-core 
CPU (X5570) and four BCM5709 NICs onboard. I would like to assign each 
NIC's interrupt to a different CPU for a better performance. However, as I 
have 5 INTs to assign and only 4 CPUs available, it is not obvious how to 
do it right:

             CPU0       CPU1       CPU2       CPU3
   61:      85085          0          0          0   PCI-MSI-edge      eth1-0
   62:      23046          0          0          0   PCI-MSI-edge      eth1-1
   63:      24525          0          0          0   PCI-MSI-edge      eth1-2
   64:      77801          0          0          0   PCI-MSI-edge      eth1-3
   65:      24006          0          0          0   PCI-MSI-edge      eth1-4

# uname -r
2.6.33.3

# dmesg |grep  0000:01:00.0
bnx2 0000:01:00.0: PCI INT A -> GSI 36 (level, low) -> IRQ 36
bnx2 0000:01:00.0: setting latency timer to 64
bnx2 0000:01:00.0: firmware: requesting bnx2/bnx2-mips-09-5.0.0.j3.fw
bnx2 0000:01:00.0: firmware: requesting bnx2/bnx2-rv2p-09-5.0.0.j3.fw
bnx2 0000:01:00.0: irq 61 for MSI/MSI-X
bnx2 0000:01:00.0: irq 62 for MSI/MSI-X
bnx2 0000:01:00.0: irq 63 for MSI/MSI-X
bnx2 0000:01:00.0: irq 64 for MSI/MSI-X
bnx2 0000:01:00.0: irq 65 for MSI/MSI-X
bnx2 0000:01:00.0: irq 66 for MSI/MSI-X
bnx2 0000:01:00.0: irq 67 for MSI/MSI-X
bnx2 0000:01:00.0: irq 68 for MSI/MSI-X
bnx2 0000:01:00.0: irq 69 for MSI/MSI-X

Why the driver registers 5 interrupts instead of 4? How to limit it to 4?

Best regards,

 				Krzysztof Olêdzki
---1144830174-573665055-1274016784=:6004--
