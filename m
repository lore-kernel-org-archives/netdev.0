From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH] r8169 tx checksuming on by default
Date: Thu, 28 Oct 2004 17:00:46 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410281700.46839.jdmason@us.ibm.com>
References: <41802CA8.8070900@candelatech.com> <20041028074827.GA3572@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041028074827.GA3572@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The tx checksumming and scatter-gather in r8169 runs well.  Below is a trivial 
patch to turn them on by default.  


--- r8169.c.orig        2004-10-28 15:02:07.000000000 -0500
+++ r8169.c     2004-10-28 15:21:03.000000000 -0500
@@ -1337,6 +1337,8 @@ rtl8169_init_one(struct pci_dev *pdev, c
        dev->poll_controller = rtl8169_netpoll;
 #endif

+       dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
+
        tp->intr_mask = 0xffff;
        tp->pci_dev = pdev;
        tp->mmio_addr = ioaddr;


-- 
Jon Mason
jdmason@us.ibm.com
