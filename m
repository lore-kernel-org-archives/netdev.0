From: Alexander Strakh <strakh@ispras.ru>
Subject: BUG null dereference in driver ./drivers/net/3c507.c
Date: Tue, 15 Dec 2009 17:55:08 +0000
Message-ID: <200912151755.08345.strakh@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Donald Becker <becker@scyld.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760232AbZLONty@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	KERNEL_VERSION: 2.6.32
	SUBJECT: null dereference aftre check
	DESCRIBE:
	In driver drivers/net/3c507.c in function Iirqreturn_t el16_interrupt:

1. If in line 555 dev = NULL then we goto line 556
2. In line 556 we have null dereference because pr_err called with dev->name 
in third parameter.

 555        if (dev == NULL) {
 556                pr_err("%s: net_interrupt(): irq %d for unknown device.
\n",
 557                        dev->name, irq);
 558                return IRQ_NONE;
 559        }

Found by Linux Device Drivers Verification Project (Svace Detector)
