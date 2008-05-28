From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: [PATCH v1.2.26] wan: new driver retina
Date: Wed, 28 May 2008 13:42:10 +0300
Message-ID: <ca0148c30805280342l39ffe387rf4c670b17804f99d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:59731 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbYE1KmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 06:42:17 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2497258wfd.4
        for <netdev@vger.kernel.org>; Wed, 28 May 2008 03:42:16 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

Adding Retina G.703 and G.SHDSL driver.

Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

---


--- next-20080519/MAINTAINERS	2008-05-19 09:34:27.000000000 +0300
+++ next/MAINTAINERS	2008-05-28 13:29:40.696224626 +0300
@@ -3428,6 +3428,12 @@ L:	reiserfs-devel@vger.kernel.org
 W:	http://www.namesys.com
 S:	Supported

+RETINA DRIVER
+P:	Matti Linnanvuori
+M:	mattilinnanvuori@yahoo.com
+L:	netdev@vger.kernel.org
+S:	Supported
+
 RFKILL
 P:	Ivo van Doorn
 M:	IvDoorn@gmail.com
--- next-20080519/drivers/net/wan/retina.h	1970-01-01 02:00:00.000000000 +0200
+++ next/drivers/net/wan/retina.h	2008-05-28 12:44:35.003335202 +0300
@@ -0,0 +1,164 @@
+/* V1.0.0 */
+
+/*
+	Copyright (C) 2002-2003 Jouni Kujala, Flexibilis Oy.
+
+	This program is free software; you can redistribute it and/or
+	modify it under the terms of the GNU General Public License
+	as published by the Free Software Foundation; either version 2
+	of the License, or (at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+	GNU General Public License for more details.
+
+	All the drivers derived from or based on this code fall under the
+	GPL and must retain the copyright and license notice.
+*/
+
+#ifndef RETINA_H
+#define RETINA_H
+
+#include <linux/ioctl.h>
+#include <linux/types.h>
+
+/* net device related stuff: */
+#define FEPCI_NETDEV_IOCTL_STREAM_BUFSIZE 0x89F1
+#define FEPCI_NETDEV_IOCTL_STREAM_UNITSIZE 0x89F2
+#define FEPCI_NETDEV_IOCTL_STREAM_OPEN 0x89F3
+#define FEPCI_NETDEV_IOCTL_STREAM_START 0x89F4
+#define FEPCI_NETDEV_IOCTL_STREAM_CLOSE 0x89F6
+
+/* char device related stuff: */
+
+#define FEPCI_SHARED_MEM_OFFSETT 0x8000
+#define FEPCI_IDENTIFICATION_OFFSETT (FEPCI_SHARED_MEM_OFFSETT+0x0)
+#define FEPCI_FEATURES_OFFSETT (FEPCI_SHARED_MEM_OFFSETT+0x40)
+#define FEPCI_SETTINGS_OFFSETT (FEPCI_SHARED_MEM_OFFSETT+0x80)
+#define FEPCI_STATUS_OFFSETT (FEPCI_SHARED_MEM_OFFSETT+0xE0)
+#define FEPCI_MAILBOX_OFFSETT (FEPCI_SHARED_MEM_OFFSETT+0x100)
+
+/* structures for ioctl calls: */
+struct fepci_ioctl_identification {
+	unsigned char data[0x20];
+};
+struct fepci_real_identification {
+	unsigned long int data[0x10];
+};
+
+struct fepci_ioctl_features {
+	unsigned char data[0x20];
+};
+struct fepci_real_features {
+	unsigned long int data[0x10];
+};
+
+struct fepci_ioctl_settings {
+	unsigned char data[0x30];
+};
+struct fepci_real_settings {
+	unsigned long int data[0x15];
+};
+
+struct fepci_ioctl_status {
+	unsigned char data[0x10];
+};
+struct fepci_real_status {
+	unsigned long int data[0x5];
+};
+
+struct fepci_ioctl_shared_mem {
+	unsigned long int data[0x80];
+};
+
+#define FEPCI_IOCTL_MAGIC 0xAA
+
+#define FEPCI_IOCTL_R_SHARED_MEM _IOR(FEPCI_IOCTL_MAGIC, 1, \
+struct fepci_ioctl_shared_mem)
+#define FEPCI_IOCTL_W_SHARED_MEM _IOW(FEPCI_IOCTL_MAGIC, 2, \
+struct fepci_ioctl_shared_mem)
+
+#define FEPCI_IOCTL_G_IDENTIFICATION _IOR(FEPCI_IOCTL_MAGIC, 0x81, \
+struct fepci_ioctl_identification)
+#define FEPCI_IOCTL_G_FEATURES _IOR(FEPCI_IOCTL_MAGIC, 0x82, \
+struct fepci_ioctl_features)
+#define FEPCI_IOCTL_G_SETTINGS _IOR(FEPCI_IOCTL_MAGIC, 0x83, \
+struct fepci_ioctl_settings)
+#define FEPCI_IOCTL_G_STATUS _IOR(FEPCI_IOCTL_MAGIC, 0x84, \
+struct fepci_ioctl_status)
+
+/* mailbox: */
+
+struct fepci_ioctl_mailbox {
+	unsigned char Semafore;
+	unsigned char Mail_number;
+	unsigned char Size;
+	unsigned char Command;
+	unsigned char Data[112];
+};
+
+struct fepci_real_mailbox {
+	__u32 Semafore_Mail_number;
+	__u32 Size_Command;
+	__u32 Data[112 / 2];
+};
+
+#define FEPCI_IOCTL_B_POLL _IO(FEPCI_IOCTL_MAGIC, 0x85)
+#define FEPCI_IOCTL_B_GRAB _IO(FEPCI_IOCTL_MAGIC, 0x86)
+#define FEPCI_IOCTL_B_RELEASE _IO(FEPCI_IOCTL_MAGIC, 0x87)
+#define FEPCI_IOCTL_B_S_CMAIL _IOW(FEPCI_IOCTL_MAGIC, 0x88, \
+struct fepci_ioctl_mailbox)
+#define FEPCI_IOCTL_B_S_QMAIL _IOW(FEPCI_IOCTL_MAGIC, 0x89, \
+struct fepci_ioctl_mailbox)
+#define FEPCI_IOCTL_B_G_MAIL _IOR(FEPCI_IOCTL_MAGIC, 0x90, \
+struct fepci_ioctl_mailbox)
+
+#define FEPCI_IOCTL_ALARM_MANAGER _IO(FEPCI_IOCTL_MAGIC, 0x91)
+#define FEPCI_IOCTL_STREAM_TRANSMIT_POLL _IO(FEPCI_IOCTL_MAGIC, 0x92)
+#define FEPCI_IOCTL_STREAM_RECEIVE_POLL _IO(FEPCI_IOCTL_MAGIC, 0x93)
+#define FEPCI_IOCTL_STREAM_BOTH_POLL _IO(FEPCI_IOCTL_MAGIC, 0x94)
+
+/* stream related stuff: */
+
+/* stream buffer address space:
+ * address: 0x 7 6 5 4   3 2 1 0
+ *              ^ ^ ^
+ *              | | |
+ *           card | area(rx/tx,0==rx,1==tx)
+ *             channel     */
+
+#define CARD_ADDRESS_SHIFT 24u
+#define CHANNEL_ADDRESS_SHIFT 20u
+#define AREA_ADDRESS_SHIFT 16u
+
+#define STREAM_BUFFER_POINTER_AREA 0x7fff0000	/* one page reserved */
+
+/* stream buffer pointers (at pointer area):
+ * address: 0x 7 6 5 4   3 2 1 0
+ *                        ^ ^ ^
+ *                        | | |
+ *                     card | area(rx/tx,0==rx,4==tx)
+ *                       channel     */
+
+#define CARD_POINTER_SHIFT 8u
+#define CHANNEL_POINTER_SHIFT 4u
+#define AREA_POINTER_SHIFT 2u
+
+/* fake pointers are for faking larger unit sizes to the user than
+ * what is the maximum internal unit size in FEPCI */
+#define USER_RX_S_FAKE_POINTER(__card, __channel, __offset) \
+((u32 *)(((__card << CARD_POINTER_SHIFT) | \
+(__channel << CHANNEL_POINTER_SHIFT) | 0x0) + __offset))
+#define USER_TX_S_FAKE_POINTER(__card, __channel, __offset) \
+((u32 *)(((__card << CARD_POINTER_SHIFT) | \
+(__channel << CHANNEL_POINTER_SHIFT) | 0x4) + __offset))
+
+#define USER_RX_S_POINTER(__card, __channel, __offset) \
+((u32 *)(((__card << CARD_POINTER_SHIFT) | \
+(__channel << CHANNEL_POINTER_SHIFT) | 0x8) + __offset))
+#define USER_TX_S_POINTER(__card, __channel, __offset) \
+((u32 *)(((__card << CARD_POINTER_SHIFT) | \
+(__channel << CHANNEL_POINTER_SHIFT) | 0xC) + __offset))
+
+#endif
--- next-20080519/drivers/net/wan/retina.c	1970-01-01 02:00:00.000000000 +0200
+++ next/drivers/net/wan/retina.c	2008-05-28 13:19:12.643980416 +0300
@@ -0,0 +1,2139 @@
+/* retina.c: */
+
+/*
+	This driver is based on:
+
+	/drivers/net/fepci.c
+	FEPCI (Frame Engine for PCI) driver for Linux operating system
+
+	Copyright (C) 2002-2003 Jouni Kujala, Flexibilis Oy.
+
+	This program is free software; you can redistribute it and/or
+	modify it under the terms of the GNU General Public License
+	as published by the Free Software Foundation; either version 2
+	of the License, or (at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+	GNU General Public License for more details.
+
+	All the drivers derived from or based on this code fall under the
+	GPL and must retain the copyright and license notice.
+*/
+
+/* need to update MODULE_PARM also */
+#define MAX_DEVICES 32u
+
+#define MAX_TX_UNITS  256u
+#define MAX_RX_UNITS  256u
+
+#define MAX_UNIT_SZ_ORDER  10u
+
+#define TX_RING_SIZE	8u
+#define RX_RING_SIZE	8u
+
+/* need to update MODULE_PARM also */
+#define CHANNELS 	4u
+
+#define RX_FIFO_THRESHOLD_PACKET_MODE 0x4
+#define TX_FIFO_THRESHOLD_PACKET_MODE 0x4
+#define TX_DESC_THRESHOLD_PACKET_MODE 0x4
+
+#define RX_FIFO_THRESHOLD_STREAM_MODE 0x4
+#define TX_FIFO_THRESHOLD_STREAM_MODE 0x7
+#define TX_DESC_THRESHOLD_STREAM_MODE 0x1
+
+#define RETINA_MRU 2000
+#define RETINA_DMA_SIZE (RETINA_MRU + 4)
+
+/* need to update MODULE_PARM also */
+#define MAX_INTERFACES (CHANNELS * MAX_DEVICES)
+
+static const char fepci_name[] = "retina";
+static const char fepci_alarm_manager_name[] = "retina alarm manager";
+static const char fepci_NAME[] = "RETINA";
+static const char fepci_netdev_name[] = "dcpxx";
+
+static unsigned int find_cnt;
+
+static int retina_noarp_with_ptp;
+
+/* Time in jiffies before concluding that the transmitter is hung. */
+#define TX_TIMEOUT (5 * HZ)
+
+#include "retina.h"
+#include <linux/mm.h>
+#include <linux/random.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/timer.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/ethtool.h>
+#include <linux/delay.h>
+#include <linux/version.h>
+#include <linux/pfn.h>
+#include <linux/uaccess.h>
+#include <linux/io.h>
+#include <linux/fs.h>
+#include <linux/rtnetlink.h>
+
+#include <asm/pgtable.h>
+
+MODULE_VERSION("1.2.26");
+
+/* PCI I/O space extent */
+enum { FEPCI_SIZE = 0x20000 };
+
+static struct pci_device_id fepci_pci_tbl[] __devinitdata = {
+	{0x1FC0, 0x0300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x1FC0, 0x0301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0,}
+};
+
+MODULE_DESCRIPTION("Frame Engine for PCI (FEPCI)");
+MODULE_AUTHOR("Jouni Kujala");
+MODULE_LICENSE("GPL");
+MODULE_DEVICE_TABLE(pci, fepci_pci_tbl);
+
+module_param(retina_noarp_with_ptp, bool, S_IRUGO);
+MODULE_PARM_DESC(retina_noarp_with_ptp,
+		 "0 to disable NOARP, 1 to enable NOARP");
+
+struct retina_address {
+	struct sk_buff *skbuff;
+	DECLARE_PCI_UNMAP_ADDR(address)
+};
+
+struct fepci_ch_private {
+	struct net_device *this_dev;
+	struct tasklet_struct transmission;
+	struct fepci_desc __iomem *tx_desc; /* Transmission ring start. */
+	struct retina_address tx[TX_RING_SIZE];
+
+	unsigned int reg_txctrl;
+	unsigned char channel_number;
+	unsigned char cur_tx;	/* the next filled tx_descriptor */
+	/* in stream mode the desc which is being transmitted */
+	/* rx_descriptor where next packet transferred */
+	unsigned char cur_rx;
+	/* in stream mode the desc which is being received */
+	bool in_eth_mode;
+
+	unsigned int reg_rxctrl;
+	struct fepci_desc __iomem *rx_desc; /* Reception ring start. */
+	struct retina_address rx[RX_RING_SIZE];
+
+	struct timer_list timer;
+	struct net_device_stats stats;
+	struct fepci_card_private *this_card_priv;
+
+/* stream mode: */
+	unsigned char bufsize_order;	/* 10=1kB,11=2kB,12=4kB...16=64kB */
+	unsigned char unit_sz_order;	/* 8=256B...14=16kB */
+	unsigned char fake_unit_sz_order;
+	bool in_stream_mode;
+	bool stream_on;
+	unsigned char cur_tx_unit;	/* last sent tx_unit */
+	/* rx_unit where to next packet is transferred */
+	unsigned char cur_rx_unit;
+	/* char device: */
+	u32 *rx_buffer;
+	u32 *tx_buffer;
+	unsigned bufsize;
+	unsigned unit_sz;
+	unsigned units;		/* 2,4,8,16,...,256 */
+	/* fake units (and pointers) are for faking larger unit sizes to
+	 * the user than what is the maximum internal unit size in FEPCI */
+	unsigned fake_unit_sz;
+	unsigned fake_units;
+	u32 *tx_unit[MAX_TX_UNITS];
+	u32 *rx_unit[MAX_RX_UNITS];
+};
+
+struct fepci_card_private {
+	unsigned int card_number;
+	uint8_t __iomem *ioaddr;
+	/* Process ID of the current mailbox user (for whom it is reserved) */
+	unsigned int ioctl_saved_pid;
+	struct pci_dev *pci_dev;
+	struct fepci_ch_private *ch_privates[CHANNELS];
+
+	wait_queue_head_t alarm_manager_wait_q;
+	struct timer_list mailbox_timer;
+
+	wait_queue_head_t stream_receive_q;
+	wait_queue_head_t stream_transmit_q;
+	wait_queue_head_t stream_both_q;
+};
+
+/* Offsets to the FEPCI registers */
+enum fepci_offsets {
+	reg_custom = 0x40,
+
+	reg_first_int_mask = 0x80,
+	reg_first_int_status = 0xc0,
+
+	reg_first_rxctrl = 0x4000,
+	to_next_rxctrl = 0x80,
+
+	reg_first_txctrl = 0x6000,
+	to_next_txctrl = 0x80,
+
+	first_rx_desc = 0x10000,
+	to_next_ch_rx_desc = 0x200,
+
+	first_tx_desc = 0x18000,
+	to_next_ch_tx_desc = 0x200,
+};
+
+enum reg_custom_bits {
+	AM_interrupt_mask = 0x1,
+	AM_interrupt_status = 0x100,
+};
+
+enum reg_receive_control {
+	Rx_fifo_threshold = 0x7,
+	Receive_enable = 0x80000000,
+};
+
+enum reg_transmit_control {
+	Tx_fifo_threshold = 0x7,
+	Tx_desc_threshold = 0x700,
+	Transmit_enable = 0x80000000,
+};
+
+enum int_bits {
+	MaskFrameReceived = 0x01, MaskRxFifoError =
+	    0x02, MaskRxFrameDroppedError = 0x04,
+	MaskFrameTransmitted = 0x40, MaskTxFifoError = 0x80,
+	MaskAllInts = 0xc7,
+	IntrFrameReceived = 0x01, IntrRxFifoError =
+	    0x02, IntrRxFrameDroppedError = 0x04,
+	IntrFrameTransmitted = 0x40, IntrTxFifoError = 0x80,
+	IntrAllInts = 0xc7,
+};
+
+/* The FEPCI Rx and Tx buffer descriptors
+ * Elements are written as 32 bit for endian portability */
+
+struct fepci_desc {
+	u32 desc_a;
+	u32 desc_b;
+};
+
+enum desc_b_bits {
+	frame_length		= 0xFFF,
+	fifo_error		= 0x10000,
+	size_error		= 0x20000,
+	crc_error		= 0x40000,
+	octet_error		= 0x80000,
+	line_error		= 0x100000,
+	enable_transfer		= 0x80000000,
+	transfer_not_done	= 0x80000000,
+};
+
+/* global variables (common to whole driver, all the cards): */
+static int major;			/* char device major number */
+static struct fepci_card_private card_privates[MAX_DEVICES];
+static unsigned long stream_pointers;
+
+static void set_int_mask(unsigned char channel, unsigned value,
+			 struct fepci_card_private *cp)
+{
+	uint8_t __iomem *address = cp->ioaddr + reg_first_int_mask;
+	const unsigned shift = 8 * channel;
+	uint32_t oldvalue = readl(address);
+	oldvalue &= ~(0xff << shift);	/* clear bits */
+	oldvalue |= value << shift;	/* set bits */
+	writel(oldvalue, address);
+}
+
+static inline void clear_int(unsigned char channel, uint32_t value,
+			     uint8_t __iomem *ioaddr)
+{
+	writel(~(value << (8 * channel)), ioaddr + reg_first_int_status);
+}
+
+static inline unsigned get_int_status(unsigned char channel,
+				      uint8_t __iomem *ioaddr)
+{
+	const uint32_t oldvalue = readl(ioaddr + reg_first_int_status);
+	return (oldvalue >> (8 * channel)) & 0xff; /* clear other bits */
+}
+
+static void fillregisterswith_00(uint8_t __iomem *ioaddr)
+{
+	writel(0x0, ioaddr + reg_first_rxctrl);
+	writel(0x0, ioaddr + reg_first_txctrl);
+	writel(0x0, ioaddr + reg_first_int_mask);
+	writel(0x0, ioaddr + reg_first_int_status);
+	writel(0x0, ioaddr + first_rx_desc);
+	writel(0x0, ioaddr + first_tx_desc);
+}
+
+static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static int fepci_open(struct net_device *dev);
+static void fepci_timer(unsigned long data);
+static void fepci_tx_timeout(struct net_device *dev);
+static void fepci_init_ring(struct net_device *dev);
+static int fepci_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static irqreturn_t fepci_interrupt(int irq, void *dev_instance);
+static int fepci_close(struct net_device *dev);
+static void fepci_close_down(struct net_device *dev,
+			     struct fepci_ch_private *fp,
+			     struct fepci_card_private *card);
+static int fepci_stream_close_down(struct net_device *dev,
+				   struct fepci_ch_private *fp);
+static struct net_device_stats *fepci_get_stats(struct net_device *dev);
+static void set_rx_mode(struct net_device *dev);
+static void fepci_remove_one(struct pci_dev *pdev);
+static void retina_tx(unsigned long channel);
+
+/* char device operations: */
+
+static ssize_t fepci_char_read(struct file *filp, char __user *buf,
+			       size_t count, loff_t *f_pos);
+static int fepci_char_open(struct inode *inode, struct file *filp);
+static int fepci_char_release(struct inode *inode, struct file *filp);
+static int fepci_char_mmap(struct file *filp, struct vm_area_struct *vma);
+static int fepci_char_ioctl(struct inode *inode, struct file *filp,
+		     unsigned int cmd, unsigned long arg);
+
+static struct file_operations fepci_char_fops = {
+	.read		= fepci_char_read,
+	.ioctl		= fepci_char_ioctl,
+	.open		= fepci_char_open,
+	.release	= fepci_char_release,
+	.mmap		= fepci_char_mmap
+};
+
+static int fepci_char_open(struct inode *inode, struct file *filp)
+{
+	unsigned int minor = MINOR(inode->i_rdev);
+	if (unlikely(minor >= find_cnt || card_privates[minor].pci_dev == NULL))
+		return -ENXIO;
+	filp->f_op = &fepci_char_fops;
+	if (unlikely(!try_module_get(THIS_MODULE)))
+		return -EBUSY;
+	return 0;
+}
+
+static int fepci_char_release(struct inode *inode, struct file *filp)
+{
+	module_put(THIS_MODULE);
+	return 0;
+}
+
+static void fepci_vma_open(struct vm_area_struct *vma)
+{
+}
+
+static void fepci_vma_close(struct vm_area_struct *vma)
+{
+	module_put(THIS_MODULE);
+}
+
+static struct vm_operations_struct fepci_vm_ops = {
+	.open	= fepci_vma_open,
+	.close	= fepci_vma_close
+};
+
+static int fepci_char_mmap(struct file *filp, struct vm_area_struct *vma)
+{
+	unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;
+	unsigned long size = vma->vm_end - vma->vm_start;
+
+	unsigned long virtual_address = 0;
+
+	vma->vm_flags |= VM_IO | VM_RESERVED;
+	vma->vm_ops = &fepci_vm_ops;
+	vma->vm_file = filp;
+
+	if (offset == STREAM_BUFFER_POINTER_AREA) {
+		virtual_address = stream_pointers;
+		if (virtual_address == 0) {
+			printk(KERN_WARNING "%s: mmap: internal error.\n",
+			       fepci_name);
+			return -ENOMEM;
+		}
+		if (size > (1 << PAGE_SHIFT)) {
+			printk(KERN_WARNING
+			       "%s: mmap: area size over range.\n", fepci_name);
+			return -EINVAL;
+		}
+	} else {
+		unsigned int page;
+
+		unsigned int card;
+		unsigned int channel;
+		unsigned int area;	/* 0=rx, 1=tx */
+
+		card = (offset >> CARD_ADDRESS_SHIFT) & 0xf;
+		channel = (offset >> CHANNEL_ADDRESS_SHIFT) & 0xf;
+		area = (offset >> AREA_ADDRESS_SHIFT) & 0xf;
+		page = (offset & 0xffff);	/* >> PAGE_SHIFT; */
+
+		if (area == 0) {
+			/* if there really is such card */
+			if (card < find_cnt && card_privates[card].pci_dev)
+				virtual_address =
+				    (unsigned long)card_privates[card].
+				    ch_privates[channel]->rx_buffer;
+			else
+				goto INVALID;
+		} else if (area == 1) {
+			/* if there really is such card */
+			if (card < find_cnt && card_privates[card].pci_dev)
+				virtual_address =
+				    (unsigned long)card_privates[card].
+				    ch_privates[channel]->tx_buffer;
+			else
+				goto INVALID;
+		} else {
+INVALID:
+			return -EINVAL;
+		}
+		if (unlikely(virtual_address == 0))
+			goto INVALID;
+	}
+
+	if (unlikely(!try_module_get(THIS_MODULE)))
+		return -EBUSY;
+
+	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	{
+		unsigned pfn = PFN_DOWN(virt_to_phys((void *)virtual_address));
+		int error = io_remap_pfn_range(vma, vma->vm_start, pfn,
+					       size, vma->vm_page_prot);
+		if (unlikely(error))
+			return error;
+	}
+	fepci_vma_open(vma);
+	return 0;
+}
+
+/* mmap operations end */
+
+/* char operations start */
+
+static int fepci_copy_to_user(unsigned long to, uint8_t __iomem *from,
+			      unsigned len, bool shrink)
+{
+	if (shrink) {
+		unsigned int i;
+		for (i = 0; i < len; i += 2) {
+			uint32_t longword = readl_relaxed(from + i / 2 *
+							  sizeof(u32));
+			int error = __put_user(longword,
+					       (unsigned char __user *)
+					       (to + i));
+			if (unlikely(error))
+				return error;
+			error = __put_user(longword >> 8,
+					   (unsigned char __user *)
+					   (to + i + 1));
+			if (unlikely(error))
+				return error;
+		}
+	} else {
+		unsigned int i;
+		for (i = 0; i < len; i += 4) {
+			uint32_t longword = readl_relaxed(from + i);
+			int error = __put_user(longword,
+					       (uint32_t __user *)(to + i));
+			if (unlikely(error))
+				return error;
+		}
+	}
+	return 0;
+}
+
+static int fepci_copy_from_user(uint8_t __iomem *to, unsigned long from,
+				unsigned len, bool enlarge)
+{
+	if (enlarge) {
+		unsigned int i;
+		for (i = 0; i < len; i += 2) {
+			unsigned char temp1;
+			unsigned char temp2;
+			int error = __get_user(temp1,
+					       (unsigned char __user *)
+					       (from + i));
+			if (unlikely(error))
+				return error;
+			error = __get_user(temp2,
+					   (unsigned char __user *)
+					   (from + i + 1));
+			if (unlikely(error))
+				return error;
+			writel(temp1 + (temp2 << 8), to + i * 2);
+		}
+	} else {
+		unsigned int i;
+		for (i = 0; i < len; i += 4) {
+			uint32_t longword;
+			int error = __get_user(longword,
+					       (u32 __user *)(from + i));
+			if (unlikely(error))
+				return error;
+			writel(longword, to + i);
+		}
+	}
+	return 0;
+}
+
+static unsigned get_semafore(struct fepci_real_mailbox __iomem *mailbox)
+{
+	unsigned semafore = readb_relaxed(&mailbox->Semafore_Mail_number);
+	return semafore;
+}
+
+static void set_semafore(struct fepci_real_mailbox __iomem *mailbox,
+			 unsigned semafore)
+{
+	uint32_t number = readl_relaxed(&mailbox->Semafore_Mail_number);
+	number = ((number & ~0xFF) | semafore) + (1 << 8);
+	writel(number, &mailbox->Semafore_Mail_number);
+}
+
+static void fepci_mailbox_timer(unsigned long data)
+{
+	struct fepci_card_private *card = (struct fepci_card_private *)data;
+	unsigned int *saved_pid = &card->ioctl_saved_pid;
+	uint8_t __iomem *ioaddr = card->ioaddr;
+	struct fepci_real_mailbox __iomem *real_mailbox =
+		(struct fepci_real_mailbox __iomem *)
+		(ioaddr + FEPCI_MAILBOX_OFFSETT);
+
+	set_semafore(real_mailbox, 0x0);
+	*saved_pid = 0;
+}
+
+static int fepci_char_ioctl(struct inode *inode, struct file *filp,
+			    unsigned int cmd, unsigned long arg)
+{
+	unsigned int minor = MINOR(inode->i_rdev);
+	uint8_t __iomem *ioaddr;
+	struct fepci_real_mailbox __iomem *real_mailbox;
+	int retval = 0;
+	unsigned int *saved_pid;
+	unsigned int my_pid;
+
+	if (unlikely(minor >= find_cnt ||
+		     card_privates[minor].pci_dev == NULL)) {
+		printk(KERN_WARNING
+		       "%s: trying to access a card that does not exist\n",
+		       fepci_NAME);
+		return -ENXIO;
+	}
+
+	if (_IOC_DIR(cmd) & _IOC_READ)
+		if (unlikely(!access_ok(VERIFY_WRITE, (void __user *)arg,
+					_IOC_SIZE(cmd))))
+			return -EFAULT;
+	if (_IOC_DIR(cmd) & _IOC_WRITE)
+		if (unlikely(!access_ok(VERIFY_READ, (void __user *)arg,
+					_IOC_SIZE(cmd))))
+			return -EFAULT;
+
+	ioaddr = card_privates[minor].ioaddr;
+	real_mailbox = (struct fepci_real_mailbox __iomem *)
+			(ioaddr + FEPCI_MAILBOX_OFFSETT);
+	saved_pid = &card_privates[minor].ioctl_saved_pid;
+	my_pid = current->pid;
+
+	switch (cmd) {
+	case FEPCI_IOCTL_STREAM_TRANSMIT_POLL:
+		/* here: arg == channel number */
+		if (unlikely(arg < 0 || arg >= CHANNELS
+		    || !(card_privates[minor].ch_privates[arg]->stream_on)))
+			return 0x2;
+		{
+			u32 pointer = *USER_TX_S_FAKE_POINTER(minor, arg,
+							      stream_pointers);
+			wait_event_interruptible((card_privates[minor].
+						  stream_transmit_q)
+						 ,
+						 (pointer !=
+						  *USER_TX_S_FAKE_POINTER
+						  (minor, arg,
+						   stream_pointers)));
+			return 0x1;
+		}
+		return retval;
+	case FEPCI_IOCTL_STREAM_RECEIVE_POLL:
+		/* here: arg == channel number */
+		if (unlikely(arg < 0 || arg >= CHANNELS
+		    || !(card_privates[minor].ch_privates[arg]->stream_on)))
+			return 0x2;
+		{
+			u32 pointer = *USER_RX_S_FAKE_POINTER(minor, arg,
+							      stream_pointers);
+			wait_event_interruptible((card_privates[minor].
+						  stream_receive_q)
+						 ,
+						 (pointer !=
+						  *USER_RX_S_FAKE_POINTER
+						  (minor, arg,
+						   stream_pointers)));
+			retval = 0x1;
+		}
+		return retval;
+	case FEPCI_IOCTL_STREAM_BOTH_POLL:
+		/* here: arg == channel number */
+		if (unlikely(arg < 0 || arg >= CHANNELS
+		    || !(card_privates[minor].ch_privates[arg]->stream_on)))
+			return 0x2;
+		{
+			u32 temp_tx_pointer =
+			    *USER_TX_S_FAKE_POINTER(minor, arg,
+						    stream_pointers);
+			u32 temp_rx_pointer =
+			    *USER_RX_S_FAKE_POINTER(minor, arg,
+						    stream_pointers);
+			wait_event_interruptible((card_privates[minor].
+						  stream_both_q)
+						 ,
+						 (temp_tx_pointer !=
+						  *USER_TX_S_FAKE_POINTER
+						  (minor, arg, stream_pointers))
+						 || (temp_rx_pointer !=
+						     *USER_RX_S_FAKE_POINTER
+						     (minor, arg,
+						      stream_pointers)));
+			retval = 0x1;
+		}
+		return retval;
+	case FEPCI_IOCTL_R_SHARED_MEM:
+		retval = fepci_copy_to_user(arg,
+					    ioaddr + FEPCI_SHARED_MEM_OFFSETT,
+					    _IOC_SIZE(cmd), 0);
+		break;
+	case FEPCI_IOCTL_W_SHARED_MEM:
+		retval = fepci_copy_from_user(ioaddr + FEPCI_SHARED_MEM_OFFSETT,
+					      arg, _IOC_SIZE(cmd), 0);
+		break;
+	case FEPCI_IOCTL_G_IDENTIFICATION:
+		retval = fepci_copy_to_user(arg,
+					    ioaddr +
+					    FEPCI_IDENTIFICATION_OFFSETT,
+					    _IOC_SIZE(cmd), 1);
+		break;
+	case FEPCI_IOCTL_G_FEATURES:
+		retval = fepci_copy_to_user(arg, ioaddr +
+						 FEPCI_FEATURES_OFFSETT,
+					    _IOC_SIZE(cmd), 1);
+		break;
+	case FEPCI_IOCTL_G_SETTINGS:
+		retval = fepci_copy_to_user(arg, ioaddr +
+						 FEPCI_SETTINGS_OFFSETT,
+					    _IOC_SIZE(cmd), 1);
+		break;
+	case FEPCI_IOCTL_G_STATUS:
+		retval = fepci_copy_to_user(arg, ioaddr + FEPCI_STATUS_OFFSETT,
+					    _IOC_SIZE(cmd), 1);
+		break;
+	case FEPCI_IOCTL_B_POLL:
+		retval = get_semafore(real_mailbox);
+		if ((retval == 0x20 || retval == 0x21 || retval == 0x40)
+		    && *saved_pid != my_pid)
+			retval = 0x7;
+		mod_timer(&card_privates[minor].mailbox_timer,
+			  jiffies + 20 * HZ);
+		break;
+	case FEPCI_IOCTL_B_GRAB:
+		if ((my_pid != *saved_pid) && (*saved_pid != 0)) {
+			retval = 0x2;
+			break;
+		}
+		if (get_semafore(real_mailbox) == 0x0) {
+			set_semafore(real_mailbox, 0x40);
+			get_semafore(real_mailbox); /* Wait for write. */
+			msleep(1);	/* delay at least 1 millisecond */
+			switch (get_semafore(real_mailbox)) {
+			case 0x40:
+				retval = 0x0;
+				*saved_pid = my_pid;
+				mod_timer(&card_privates[minor].mailbox_timer,
+					  jiffies + 20 * HZ);
+				break;
+			case 0x10:
+			case 0x11:
+			case 0x80:
+				retval = 0x1;
+				break;
+			default:
+				retval = 0xff;
+			}
+		} else {
+			switch (get_semafore(real_mailbox)) {
+			case 0x10:
+			case 0x11:
+			case 0x80:
+				retval = 0x1;
+				break;
+			default:
+				retval = 0xff;
+			}
+		}
+		break;
+	case FEPCI_IOCTL_B_RELEASE:
+		if (my_pid != *saved_pid) {
+			retval = 0x2;
+			break;
+		}
+		switch (get_semafore(real_mailbox)) {
+		case 0x40:
+		case 0x20:
+			retval = 0x0;
+			set_semafore(real_mailbox, 0x0);
+			*saved_pid = 0;
+			del_timer(&card_privates[minor].mailbox_timer);
+			break;
+		case 0x21:
+			retval = 0x04;
+			break;
+		case 0x10:
+		case 0x11:
+		case 0x80:
+			retval = 0x1;
+			break;
+		default:
+			retval = 0xff;
+		}
+		break;
+	case FEPCI_IOCTL_B_S_CMAIL:
+		if (my_pid != *saved_pid) {
+			retval = 0x2;
+			break;
+		}
+		switch (get_semafore(real_mailbox)) {
+		case 0x40:
+		case 0x20:
+		case 0x21:
+			/* copy the mailbox */
+			retval = fepci_copy_from_user(ioaddr +
+						FEPCI_MAILBOX_OFFSETT + 4,
+						arg + 2, _IOC_SIZE(cmd) - 2, 1);
+			/* semafore -> 10 */
+			set_semafore(real_mailbox, 0x10);
+			mod_timer(&card_privates[minor].mailbox_timer,
+				  jiffies + 20 * HZ);
+			break;
+		case 0x10:
+		case 0x11:
+		case 0x80:
+			retval = 0x1;
+			break;
+		case 0x0:
+			retval = 0x3;
+			break;
+		default:
+			retval = 0xff;
+		}
+		break;
+	case FEPCI_IOCTL_B_S_QMAIL:
+		if (my_pid != *saved_pid) {
+			retval = 0x2;
+			break;
+		}
+		switch (get_semafore(real_mailbox)) {
+		case 0x40:
+		case 0x20:
+		case 0x21:
+			/* copy the mailbox; */
+			retval = fepci_copy_from_user(ioaddr +
+						FEPCI_MAILBOX_OFFSETT + 4,
+						arg + 2, _IOC_SIZE(cmd) - 2, 1);
+			/* semafore -> 11 */
+			set_semafore(real_mailbox, 0x11);
+			mod_timer(&card_privates[minor].mailbox_timer,
+				  jiffies + 20 * HZ);
+			break;
+		case 0x10:
+		case 0x11:
+		case 0x80:
+			retval = 0x1;
+			break;
+		case 0x0:
+			retval = 0x3;
+			break;
+		default:
+			retval = 0xff;
+		}
+		break;
+	case FEPCI_IOCTL_B_G_MAIL:
+		if (my_pid != *saved_pid) {
+			retval = 0x2;
+		} else {
+			switch (get_semafore(real_mailbox)) {
+			case 0x10:
+			case 0x11:
+			case 0x80:
+				retval = 0x1;
+				break;
+			case 0x40:
+			case 0x20:
+			case 0x21:
+				retval = fepci_copy_to_user(arg,
+							ioaddr +
+							FEPCI_MAILBOX_OFFSETT,
+							_IOC_SIZE(cmd), 1);
+				mod_timer(&card_privates[minor].mailbox_timer,
+					  jiffies + 20 * HZ);
+				break;
+			case 0x0:
+				retval = 0x3;
+				break;
+			default:
+				retval = 0xff;
+			}
+		}
+		if (unlikely(retval != 0)) {
+			/* copy four lowest bytes from the mailbox */
+			retval = fepci_copy_to_user(arg,
+						ioaddr + FEPCI_MAILBOX_OFFSETT,
+						4, 1);
+			if (likely(retval == 0))
+				/* lowest byte = 0x7 */
+				retval = __put_user(7, (char __user *)arg);
+		}
+		break;
+	case FEPCI_IOCTL_ALARM_MANAGER:
+		interruptible_sleep_on(&(card_privates[minor].
+					 alarm_manager_wait_q));
+		return retval;
+	default:
+		dev_warn(&card_privates[minor].pci_dev->dev,
+			 "unknown ioctl command 0x%x.\n", cmd);
+		return -ENOTTY;
+	}
+	return retval;
+}
+
+static ssize_t fepci_char_read(struct file *filp, char __user *buf,
+			       size_t count, loff_t *f_pos)
+{
+	if (count > 1)
+		count = 1;
+	if (unlikely(copy_to_user(buf, "\n", count)))
+		return -EFAULT;
+	return count;
+}
+
+static int fepci_register_char_device(void)
+{
+	int error =
+		register_chrdev(0 /* dynamic */ , fepci_name, &fepci_char_fops);
+	if (unlikely(error < 0))
+		printk(KERN_WARNING
+		       "%s: unable to register char device\n", fepci_NAME);
+	return error;
+}
+
+static void fepci_unregister_char_device(void)
+{
+	unregister_chrdev(major, fepci_name);
+}
+
+/* char operations end */
+
+/* stream operations start */
+
+static irqreturn_t fepci_stream_interrupt(int irq, void *dev_instance);
+
+static int fepci_stream_open_down(struct net_device *dev,
+				  struct fepci_ch_private *fp)
+{
+	unsigned tx_pages, rx_pages, tx_order, rx_order;
+	unsigned page_number;
+	unsigned int i;
+
+	if (unlikely(fp->in_eth_mode)) {
+		dev_warn(&dev->dev,
+			 "Interface is in Ethernet mode, "
+			 "cannot open stream interface\n");
+		return -EBUSY;
+	}
+	if (unlikely(fp->in_stream_mode))
+		return 0;
+
+	if (unlikely(fp->this_card_priv->pci_dev == NULL))
+		return -ENXIO;
+
+	fp->bufsize = 1 << fp->bufsize_order;
+
+	if (unlikely(fp->fake_unit_sz_order < 5)) {
+		dev_warn(&dev->dev, "Unit size has to be at least 32 bytes\n");
+INVALID:
+		return -EINVAL;
+	}
+
+	if (unlikely(fp->fake_unit_sz_order >= fp->bufsize_order)) {
+		dev_warn(&dev->dev,
+			 "Bufsize has to be greater than unit size\n");
+		goto INVALID;
+	}
+
+	if (fp->fake_unit_sz_order >= MAX_UNIT_SZ_ORDER)
+		fp->unit_sz_order = MAX_UNIT_SZ_ORDER;
+	else
+		fp->unit_sz_order = fp->fake_unit_sz_order;
+
+	fp->fake_unit_sz = 1 << fp->fake_unit_sz_order;
+	fp->unit_sz = 1 << fp->unit_sz_order;
+	fp->units = 1 << (fp->bufsize_order - fp->unit_sz_order);
+	fp->fake_units = 1 << (fp->bufsize_order - fp->fake_unit_sz_order);
+
+	/* reserve memory */
+	if (fp->bufsize_order < PAGE_SHIFT) {
+		rx_order = 0;
+		tx_order = 0;
+		rx_pages = 1;
+		tx_pages = 1;
+	} else {
+		tx_order = fp->bufsize_order - PAGE_SHIFT;
+		tx_pages = 1 << tx_order;
+		rx_order = tx_order + 1;
+		rx_pages = 1 << rx_order;
+	}
+	fp->in_stream_mode = 1;
+	fp->tx_buffer = (u32 *) __get_free_pages(GFP_KERNEL, tx_order);
+	if (unlikely(!fp->tx_buffer))
+		goto NO_MEMORY;
+	fp->rx_buffer = (u32 *) __get_free_pages(GFP_KERNEL, rx_order);
+	if (unlikely(!fp->rx_buffer)) {
+NO_MEMORY:
+		dev_warn(&dev->dev, "unable to allocate memory for buffers\n");
+		fepci_stream_close_down(dev, fp);
+		return -ENOMEM;
+	}
+
+	for (page_number = 0; page_number < rx_pages; page_number++)
+		/* make pages reserved to allow remappping pages
+		   with io_remap_pfn_range */
+		SetPageReserved(virt_to_page
+				((unsigned long)fp->rx_buffer +
+				 (page_number << PAGE_SHIFT)));
+	for (page_number = 0; page_number < tx_pages; page_number++)
+		/* make pages reserved to allow remappping pages
+		   with io_remap_pfn_range */
+		SetPageReserved(virt_to_page
+				((unsigned long)fp->tx_buffer +
+				 (page_number << PAGE_SHIFT)));
+
+	for (i = 0; i < (fp->bufsize) / 4; i++)
+		fp->tx_buffer[i] = 0xffffffff;
+
+	/* + fp->channel_number; */
+	*USER_RX_S_POINTER(fp->this_card_priv->card_number, fp->channel_number,
+			   stream_pointers) = 0;
+	/* + fp->channel_number; */
+	*USER_TX_S_POINTER(fp->this_card_priv->card_number, fp->channel_number,
+			   stream_pointers) = 0;
+	/* + fp->channel_number; */
+	*USER_RX_S_FAKE_POINTER(fp->this_card_priv->card_number,
+				fp->channel_number, stream_pointers) = 0;
+	/* + fp->channel_number; */
+	*USER_TX_S_FAKE_POINTER(fp->this_card_priv->card_number,
+				fp->channel_number, stream_pointers) = 0;
+
+	dev_dbg(&dev->dev, "Bufsize is 0x%x.\n", fp->bufsize);
+	dev_dbg(&dev->dev, "Unit_size is 0x%x.\n", fp->unit_sz);
+	dev_dbg(&dev->dev, "Number of units is 0x%x.\n", fp->units);
+
+	dev_dbg(&dev->dev, "Fake_unit_size is 0x%x.\n", fp->fake_unit_sz);
+	dev_dbg(&dev->dev, "Number of fake units is 0x%x.\n", fp->fake_units);
+
+	/* init ring buffers */
+	for (i = 0; i < MAX_RX_UNITS; i++)
+		fp->rx_unit[i] =
+		    (u32 *) ((u32) (fp->rx_buffer) + (fp->unit_sz * i));
+	for (i = 0; i < MAX_TX_UNITS; i++)
+		fp->tx_unit[i] =
+		    (u32 *) ((u32) (fp->tx_buffer) + (fp->unit_sz * i));
+
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		writel(0, &fp->rx_desc[i].desc_a);
+		writel(0, &fp->rx_desc[i].desc_b);
+	}
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		writel(0, &fp->tx_desc[i].desc_a);
+		writel(0, &fp->tx_desc[i].desc_b);
+	}
+	return 0;
+}
+
+static int fepci_stream_start_down(struct net_device *dev,
+				   struct fepci_ch_private *fp)
+{
+	unsigned i;
+
+	if (unlikely(!fp->in_stream_mode)) {
+		dev_warn(&dev->dev,
+			 "Interface is not in stream mode, "
+			 "streaming cannot be started\n");
+		return -EBUSY;
+	}
+	if (unlikely(fp->stream_on))
+		return 0;
+
+	{
+		/* reserve irq */
+		int error = request_irq(dev->irq, &fepci_stream_interrupt,
+					IRQF_SHARED, dev->name, dev);
+		if (unlikely(error)) {
+			dev_warn(&dev->dev,
+				 "unable to allocate IRQ %d, error 0x%x\n",
+				 dev->irq, error);
+			return -ENOMEM;
+		}
+	}
+
+	fp->stream_on = 1;
+
+	/* sending &receiving on, start from the beginning of the buffer */
+	fp->cur_tx_unit = 0;
+	fp->cur_rx_unit = 0;
+	fp->cur_tx = 0;
+	fp->cur_rx = 0;
+
+	/* all the descriptors ready to go: */
+	for (i = 0; i < min(RX_RING_SIZE, TX_RING_SIZE); i++) {
+		dma_addr_t address = pci_map_single(fp->this_card_priv->pci_dev,
+						    fp->
+						    rx_unit[(fp->cur_rx_unit +
+							     i) % fp->units],
+						    fp->unit_sz,
+						    PCI_DMA_FROMDEVICE);
+		if (unlikely(pci_dma_mapping_error(address))) {
+			dev_warn(&dev->dev, "failed to map DMA buffer\n");
+		} else {
+			unsigned next = (fp->cur_rx + i) & (RX_RING_SIZE - 1);
+			pci_unmap_addr_set(fp->rx + next, address, address);
+			writel(address, &fp->rx_desc[next].desc_a);
+			if (!(readl(&fp->rx_desc[next].desc_b) &
+			      enable_transfer))
+				writel(enable_transfer,
+				       &fp->rx_desc[next].desc_b);
+		}
+		address = pci_map_single(fp->this_card_priv->pci_dev,
+					 fp->tx_unit[(fp->cur_tx_unit + i) %
+					 fp->units], fp->unit_sz,
+					 PCI_DMA_TODEVICE);
+		if (unlikely(pci_dma_mapping_error(address))) {
+			dev_warn(&dev->dev, "failed to map DMA buffer\n");
+		} else {
+			unsigned next = (fp->cur_tx + i) & (TX_RING_SIZE - 1);
+			pci_unmap_addr_set(fp->tx + next, address, address);
+			writel(address, &fp->tx_desc[next].desc_a);
+			if (!(readl_relaxed(&fp->tx_desc[next].desc_b) &
+			      enable_transfer))
+				writel(enable_transfer |
+				       (fp->unit_sz & frame_length),
+				       &fp->tx_desc[next].desc_b);
+		}
+	}
+
+	/* irq on */
+	set_int_mask(fp->channel_number,
+		     MaskFrameReceived | MaskFrameTransmitted |
+		     MaskRxFifoError | MaskRxFrameDroppedError |
+		     MaskTxFifoError, fp->this_card_priv);
+	{
+		uint8_t __iomem *ioaddr = (uint8_t __iomem *)dev->base_addr;
+		/* Start Rx and Tx channels */
+		writel(Receive_enable |
+		       (Rx_fifo_threshold & RX_FIFO_THRESHOLD_STREAM_MODE),
+		       ioaddr + fp->reg_rxctrl);
+		writel((Transmit_enable |
+			(Tx_desc_threshold &
+			 (TX_DESC_THRESHOLD_STREAM_MODE << 8)) |
+			(Tx_fifo_threshold & TX_FIFO_THRESHOLD_STREAM_MODE)),
+		       ioaddr + fp->reg_txctrl);
+	}
+
+	return 0;
+}
+
+static inline void fepci_stream_stop(struct net_device *dev,
+				     struct fepci_ch_private *fp)
+{
+	uint8_t __iomem *ioaddr = (uint8_t __iomem *)dev->base_addr;
+	fp->stream_on = 0;
+	/* Stop Rx and Tx channels. */
+	writel(0x0, ioaddr + fp->reg_rxctrl);
+	writel(0x0, ioaddr + fp->reg_txctrl);
+
+	/* Disable interrupts by clearing the interrupt mask. */
+	set_int_mask(fp->channel_number, 0x0, fp->this_card_priv);
+
+	/* unregister irq */
+	free_irq(dev->irq, dev);
+
+	{
+		unsigned i = min(RX_RING_SIZE, TX_RING_SIZE) - 1;
+		do {
+			if (likely(!pci_dma_mapping_error(
+				pci_unmap_addr(fp->rx + i, address))))
+				pci_unmap_single(fp->this_card_priv->
+						 pci_dev,
+						 pci_unmap_addr(fp->rx + i,
+								address),
+						 fp->unit_sz,
+						 PCI_DMA_FROMDEVICE);
+			if (likely(!pci_dma_mapping_error(
+				pci_unmap_addr(fp->tx + i, address))))
+				pci_unmap_single(fp->this_card_priv->
+						 pci_dev,
+						 pci_unmap_addr(fp->tx + i,
+								address),
+						 fp->unit_sz, PCI_DMA_TODEVICE);
+		} while (i--);
+	}
+}
+
+static int fepci_stream_close_down(struct net_device *dev,
+				   struct fepci_ch_private *fp)
+{
+	unsigned rx_pages, tx_pages, rx_order, tx_order;
+
+	if (unlikely(!(fp->in_stream_mode)))
+		return -EBUSY;
+	fepci_stream_stop(dev, fp);
+	/* release memory */
+	if (fp->bufsize_order < PAGE_SHIFT) {
+		rx_order = 0;
+		tx_order = 0;
+		rx_pages = 1;
+		tx_pages = 1;
+	} else {
+		rx_order = (int)((fp->bufsize_order) - PAGE_SHIFT + 1);
+		rx_pages = 1 << rx_order;
+		tx_order = (int)((fp->bufsize_order) - PAGE_SHIFT);
+		tx_pages = 1 << tx_order;
+	}
+	if (fp->rx_buffer) {
+		unsigned page_number;
+		for (page_number = 0; page_number < rx_pages; page_number++)
+			/* turn pages back to non-reserved */
+			ClearPageReserved(virt_to_page
+					  ((unsigned long)fp->rx_buffer +
+					   (page_number << PAGE_SHIFT)));
+		free_pages((unsigned long)fp->rx_buffer, rx_order);
+		fp->rx_buffer = NULL;
+	}
+	if (fp->tx_buffer) {
+		unsigned page_number;
+		for (page_number = 0; page_number < tx_pages; page_number++)
+			/* turn pages back to non-reserved */
+			ClearPageReserved(virt_to_page
+					  ((unsigned long)fp->tx_buffer +
+					   (page_number << PAGE_SHIFT)));
+		free_pages((unsigned long)fp->tx_buffer, tx_order);
+		fp->tx_buffer = NULL;
+	}
+	fp->in_stream_mode = 0;
+	return 0;
+}
+
+static irqreturn_t fepci_stream_interrupt(int irq, void *dev_instance)
+{
+	struct net_device *dev = dev_instance;
+	struct fepci_ch_private *fp = netdev_priv(dev);
+	uint8_t __iomem *ioaddr = (uint8_t __iomem *)dev->base_addr;
+	const unsigned char channel = fp->channel_number;
+	const uint32_t intr_status = get_int_status(channel, ioaddr);
+	unsigned int temp_rx;
+	unsigned int temp_rx_unit;
+	unsigned int temp_tx;
+	unsigned int temp_tx_unit;
+	if (!intr_status)
+		return IRQ_NONE;
+	clear_int(channel, intr_status, ioaddr);
+	/* First update cur_rx, and do stuff if it has moved
+	   (+ packets have been received). */
+	temp_rx = fp->cur_rx;
+	while ((readl(&fp->rx_desc[fp->cur_rx].desc_b) &
+		transfer_not_done) == 0 /* has been received */
+	       /* Stop if made one round. */
+	       && temp_rx != ((fp->cur_rx + 1) & (RX_RING_SIZE - 1))) {
+		if (likely(!pci_dma_mapping_error(
+			pci_unmap_addr(fp->rx + fp->cur_rx, address))))
+			pci_unmap_single(fp->this_card_priv->pci_dev,
+					 pci_unmap_addr(fp->rx + fp->cur,
+							address),
+					 fp->unit_sz, PCI_DMA_FROMDEVICE);
+		fp->cur_rx = (fp->cur_rx + 1) & (RX_RING_SIZE - 1);
+		fp->cur_rx_unit = (fp->cur_rx_unit + 1);
+		fp->cur_rx_unit *= fp->cur_rx_unit < fp->units;
+		*USER_RX_S_POINTER(fp->this_card_priv->card_number,
+				   fp->channel_number,
+				   stream_pointers) = fp->cur_rx_unit;
+		*USER_RX_S_FAKE_POINTER(fp->this_card_priv->card_number,
+					fp->channel_number,
+					stream_pointers) =
+			fp->cur_rx_unit * fp->unit_sz / fp->fake_unit_sz;
+		wake_up_interruptible(&(fp->this_card_priv->stream_receive_q));
+		wake_up_interruptible(&(fp->this_card_priv->stream_both_q));
+	}
+	/* from the first uninitialized descriptor to cur_rx */
+	temp_rx = (fp->cur_rx + 1) & (RX_RING_SIZE - 1);
+	temp_rx_unit = (fp->cur_rx_unit + 1);
+	temp_rx_unit *= temp_rx_unit < fp->units;
+	while (temp_rx != fp->cur_rx) {
+		uint32_t desc_b = readl(&fp->rx_desc[temp_rx].desc_b);
+		if ((desc_b & transfer_not_done) == 0) {
+			dma_addr_t bus_address;
+			/* Update debug counters. */
+			if (unlikely(desc_b & fifo_error)) {
+				fp->stats.rx_errors++;
+				fp->stats.rx_frame_errors++;
+			} else if (unlikely(desc_b & size_error)) {
+				fp->stats.rx_errors++;
+				fp->stats.rx_over_errors++;
+			} else if (unlikely(desc_b & (octet_error |
+						      line_error))) {
+				fp->stats.rx_errors++;
+			}
+			/* Initialize the descriptor for transfer. */
+			bus_address =
+				pci_map_single(fp->this_card_priv->pci_dev,
+					       fp->rx_unit[temp_rx_unit],
+					       fp->unit_sz, PCI_DMA_FROMDEVICE);
+			if (likely(!pci_dma_mapping_error(bus_address))) {
+				pci_unmap_addr_set(fp->rx + temp_rx, address,
+						   bus_address);
+				writel(bus_address,
+					  &fp->rx_desc[temp_rx].desc_a);
+				writel(enable_transfer,
+					  &fp->rx_desc[temp_rx].desc_b);
+			} else {
+				dev_warn(&dev->dev,
+					 "failed to map DMA for reception\n");
+			}
+		}
+		temp_rx = (temp_rx + 1) & (RX_RING_SIZE - 1);
+		temp_rx_unit = (temp_rx_unit + 1);
+		temp_rx_unit *= temp_rx_unit < fp->units;
+	}
+
+	/* first update cur_tx, and do stuff if it has moved
+	   (+ packets have been transmitted) */
+	temp_tx = fp->cur_tx;
+	/* has been transmitted? */
+	while ((readl_relaxed(&fp->tx_desc[fp->cur_tx].desc_b) &
+		transfer_not_done) == 0
+		/* stop if made one round */
+	       && temp_tx != ((fp->cur_tx + 1) & (TX_RING_SIZE - 1))) {
+		if (likely(!pci_dma_mapping_error(
+			pci_unmap_addr(fp->tx + fp->cur_tx, address))))
+			pci_unmap_single(fp->this_card_priv->pci_dev,
+					 pci_unmap_addr(fp->tx + fp->cur_tx,
+							address),
+					 fp->unit_sz, PCI_DMA_TODEVICE);
+		fp->cur_tx = (fp->cur_tx + 1) & (TX_RING_SIZE - 1);
+		fp->cur_tx_unit = (fp->cur_tx_unit + 1);
+		fp->cur_tx_unit *= fp->cur_tx_unit < fp->units;
+			*USER_TX_S_POINTER(fp->this_card_priv->card_number,
+					   fp->channel_number,
+					   stream_pointers) = fp->cur_tx_unit;
+		*USER_TX_S_FAKE_POINTER(fp->this_card_priv->
+					card_number,
+					fp->channel_number,
+					stream_pointers) =
+			fp->cur_tx_unit * fp->unit_sz / fp->fake_unit_sz;
+		wake_up_interruptible(&(fp->this_card_priv->
+					stream_transmit_q));
+		wake_up_interruptible(&(fp->this_card_priv->
+					stream_both_q));
+	}
+
+	/* from the first uninitialized descriptor to cur_tx */
+	temp_tx = (fp->cur_tx + 1) & (TX_RING_SIZE - 1);
+	temp_tx_unit = (fp->cur_tx_unit + 1);
+	temp_tx_unit *= temp_tx_unit < fp->units;
+
+	while (temp_tx != fp->cur_tx) {
+		uint32_t desc_b = readl_relaxed(&fp->tx_desc[temp_tx].desc_b);
+		if ((desc_b & transfer_not_done) == 0) {
+			dma_addr_t bus_address;
+			/* update debug counters */
+			if (unlikely(desc_b & fifo_error))
+				fp->stats.tx_fifo_errors++;
+			/* initialize the descriptor for transfer */
+			bus_address =
+				pci_map_single(fp->this_card_priv->pci_dev,
+					       fp->tx_unit[temp_tx_unit],
+					       fp->unit_sz, PCI_DMA_TODEVICE);
+			if (likely(!pci_dma_mapping_error(bus_address))) {
+				pci_unmap_addr_set(fp->tx + temp_tx,
+						   address, bus_address);
+				writel(bus_address,
+				       &fp->tx_desc[temp_tx].desc_a);
+				writel(enable_transfer |
+				       (fp->unit_sz & frame_length),
+				       &fp->tx_desc[temp_tx].desc_b);
+			} else {
+				dev_warn(&dev->dev,
+					 "failed to map transmission DMA\n");
+			}
+		}
+		temp_tx = (temp_tx + 1) & (TX_RING_SIZE - 1);
+		temp_tx_unit = (temp_tx_unit + 1);
+		temp_tx_unit *= temp_tx_unit < fp->units;
+	}
+
+	return IRQ_HANDLED;
+}
+
+/* stream operations end */
+
+static int fepci_rebuild_header(struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline u16 get_common_reg_word(uint8_t __iomem *ioaddr,
unsigned offsett)
+{
+	u16 word = readw_relaxed(ioaddr + FEPCI_IDENTIFICATION_OFFSETT +
+				 (offsett << 1));
+	return word;
+}
+
+static irqreturn_t alarm_manager_interrupt(int irq, void *pointer)
+{
+	struct fepci_card_private *card_private = pointer;
+	uint8_t __iomem *ioaddr_reg_custom = card_private->ioaddr + reg_custom;
+	if (readl_relaxed(ioaddr_reg_custom) & AM_interrupt_status) {
+		/* clear interrupt (zero everything but the mask bit) */
+		writel(AM_interrupt_mask, ioaddr_reg_custom);
+		/* wake queue */
+		wake_up(&(card_private->alarm_manager_wait_q));
+		return IRQ_HANDLED;
+	} else {
+		return IRQ_NONE;
+	}
+}
+
+static struct header_ops retina_ops;
+
+static int __devinit fepci_init_one(struct pci_dev *pdev,
+				    const struct pci_device_id *ent)
+{
+	int i;
+	unsigned j;
+	uint8_t __iomem *ioaddr;
+	unsigned position;
+	struct fepci_card_private *card_private;
+	if (PCI_FUNC(pdev->devfn) != 0)
+		return -ENXIO;
+	i = pci_enable_device(pdev);
+	if (unlikely(i)) {
+		dev_warn(&pdev->dev, "pci_enable_device returned %d\n", i);
+		return i;
+	}
+	pci_set_master(pdev);
+	i = pci_request_regions(pdev, (char *)fepci_name);
+	if (unlikely(i)) {
+		dev_warn(&pdev->dev, "pci_request_regions returned %d\n", i);
+		pci_disable_device(pdev);
+		return i;
+	}
+	i = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	if (unlikely(i)) {
+		dev_warn(&pdev->dev, "no suitable DMA available\n");
+		goto ERR_1;
+	}
+	if (unlikely(pci_resource_len(pdev, 0) < FEPCI_SIZE)) {
+		dev_warn(&pdev->dev, "resource length less than required %u\n",
+			 FEPCI_SIZE);
+		i = -ENXIO;
+		goto ERR_1;
+	}
+	if (unlikely(!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM))) {
+		i = -ENXIO;
+		goto ERR_1;
+	}
+	ioaddr = pci_iomap(pdev, 0, FEPCI_SIZE);
+	if (unlikely(!ioaddr)) {
+		dev_warn(&pdev->dev, "mapping failed\n");
+		i = -ENOMEM;
+		goto ERR_1;
+	}
+	position = 0;
+	for (; position < MAX_DEVICES; position++) {
+		card_private = &card_privates[position];
+		if (card_private->pci_dev == NULL) {
+			card_private->pci_dev = pdev;
+			if (position == find_cnt)
+				find_cnt++;
+			goto FOUND;
+		}
+	}
+	dev_warn(&pdev->dev, "no space to inialize device #%u\n",
+		 MAX_DEVICES + 1);
+	i = -ENOMEM;
+	goto ERR_2;
+FOUND:
+	pci_set_drvdata(pdev, card_private);
+	card_private->card_number = position;
+	card_private->ioaddr = ioaddr;
+	card_private->pci_dev = pdev;
+	fillregisterswith_00(ioaddr);
+	init_waitqueue_head(&(card_private->alarm_manager_wait_q));
+	init_waitqueue_head(&(card_private->stream_transmit_q));
+	init_waitqueue_head(&(card_private->stream_receive_q));
+	init_waitqueue_head(&(card_private->stream_both_q));
+	setup_timer(&card_private->mailbox_timer, fepci_mailbox_timer,
+		    (unsigned long)card_private);
+	i = request_irq(pdev->irq, &alarm_manager_interrupt,
+			IRQF_SHARED, fepci_alarm_manager_name, card_private);
+	if (unlikely(i)) {
+		dev_warn(&pdev->dev,
+			 "unable to allocate alarm manager IRQ %u: %d\n",
+			 pdev->irq, i);
+		goto ERR_2;
+	}
+	writel(AM_interrupt_mask, ioaddr + reg_custom);
+	/* alarm manager interrupt on */
+	for (j = 0; j < CHANNELS; j++) {
+		char *name;
+		struct fepci_ch_private *fp;
+		struct net_device *dev =
+			alloc_etherdev(sizeof(struct fepci_ch_private));
+		if (unlikely(!dev)) {
+			dev_warn(&pdev->dev,
+				 "cannot allocate Ethernet device\n");
+			continue;
+		}
+		fp = netdev_priv(dev);
+		card_private->ch_privates[j] = fp;
+		name = dev->name;
+		/* name := xxx01..xxxnn */
+		memcpy(name, fepci_netdev_name, 6);
+		/* dev->name[3]= j+'0';    channel number -> ascii */
+		/* minor number -> ascii */
+		name[4] = ((position * CHANNELS + j) % 10) + '0';
+		/* minor number -> ascii */
+		name[3] = ((position * CHANNELS + j) / 10) + '0';
+		clear_int(j, IntrAllInts, ioaddr);
+		ether_setup(dev);
+		/* HW_ADDR is got using the mailbox: */
+		{
+			struct fepci_real_mailbox __iomem *real_mailbox =
+				(struct fepci_real_mailbox __iomem *)
+				(ioaddr + FEPCI_MAILBOX_OFFSETT);
+			unsigned long waituntil;
+			uint8_t *address = dev->dev_addr;
+			set_semafore(real_mailbox, 0x40);
+			writel(0x1 /* size */ +
+			       (0x8 << 8) /* get mac command */,
+			       &real_mailbox->Size_Command);
+			set_semafore(real_mailbox, 0x11);
+			waituntil = jiffies + HZ;
+			while (time_before(jiffies, waituntil) &&
+			       get_semafore(real_mailbox) != 0x20) {
+				schedule_timeout_uninterruptible(HZ / 1000);
+			}
+			if (get_semafore(real_mailbox) == 0x20) {
+				u32 __iomem *data = real_mailbox->Data + 3 * j;
+				address[5] = readb_relaxed(data);
+				address[4] = readb_relaxed(((u8 __iomem *) data)
+							   + 1);
+				address[3] = readb_relaxed(++data);
+				address[2] = readb_relaxed(((u8 __iomem *) data)
+							   + 1);
+				address[1] = readb_relaxed(++data);
+				address[0] = readb_relaxed(((u8 __iomem *) data)
+							   + 1);
+				if (unlikely(!is_valid_ether_addr(address)))
+					goto RANDOM;
+			} else {
+RANDOM:				random_ether_addr(address);
+			}
+			set_semafore(real_mailbox, 0x0);
+		}
+		dev->addr_len = 6;
+		dev->base_addr = (unsigned long)ioaddr;
+		dev->irq = pdev->irq;
+		fp->rx_desc = (struct fepci_desc __iomem *)
+			(ioaddr + first_rx_desc + j * to_next_ch_rx_desc);
+		fp->tx_desc = (struct fepci_desc __iomem *)
+			(ioaddr + first_tx_desc + j * to_next_ch_tx_desc);
+		fp->channel_number = j;	/* channel in this device */
+		fp->this_dev = dev;
+		fp->this_card_priv = card_private;
+		fp->cur_tx = 0;
+		fp->in_stream_mode = 0;
+		fp->in_eth_mode = 0;
+		fp->reg_rxctrl = reg_first_rxctrl + j * to_next_rxctrl;
+		fp->reg_txctrl = reg_first_txctrl + j * to_next_txctrl;
+		/* The FEPCI specific entries in the device structure */
+		dev->open = &fepci_open;
+		dev->hard_start_xmit = &fepci_start_xmit;
+		dev->stop = &fepci_close;
+		dev->get_stats = &fepci_get_stats;
+		dev->set_multicast_list = &set_rx_mode;
+		dev->do_ioctl = &netdev_ioctl;
+		dev->tx_timeout = fepci_tx_timeout;
+		dev->watchdog_timeo = TX_TIMEOUT;
+		tasklet_init(&fp->transmission, retina_tx, (unsigned long)fp);
+		dev->flags |= IFF_POINTOPOINT;
+		dev->flags &= ~(IFF_BROADCAST | IFF_MULTICAST);
+		if (retina_noarp_with_ptp) {
+			memcpy(&retina_ops, dev->header_ops,
+			       sizeof(retina_ops));
+			retina_ops.rebuild = fepci_rebuild_header;
+			dev->header_ops = &retina_ops;
+			dev->flags |= IFF_NOARP;
+		}
+		SET_NETDEV_DEV(dev, &pdev->dev);
+		i = register_netdev(dev);
+		if (unlikely(i)) {
+			dev_warn(&dev->dev, "register_netdev failed: %d\n", i);
+			continue;
+		}
+	}
+	return 0;
+ERR_2:
+	iounmap(ioaddr);
+	pci_set_drvdata(pdev, NULL);
+ERR_1:
+	pci_disable_device(pdev);
+	pci_release_regions(pdev);
+	return i;
+}
+
+static int fepci_open_down(struct net_device *dev, struct fepci_ch_private *fp)
+{
+	if (unlikely(fp->this_card_priv->pci_dev == NULL))
+		return -ENXIO;
+
+	{
+		int i = request_irq(dev->irq, &fepci_interrupt,
+				    IRQF_SHARED, dev->name, dev);
+		if (i) {
+			dev_warn(&dev->dev,
+				 "unable to allocate IRQ %d, error 0x%x\n",
+				 dev->irq, i);
+			return i;
+		}
+	}
+
+	fp->in_eth_mode = 1;
+
+	fepci_init_ring(dev);
+	set_rx_mode(dev);
+
+	fp->cur_rx = 0;
+	fp->cur_tx = 0;
+
+	netif_carrier_off(dev);
+
+	/* Enable interrupts by setting the interrupt mask. */
+
+	set_int_mask(fp->channel_number,
+		     MaskFrameReceived | MaskFrameTransmitted |
+		     MaskRxFifoError | MaskRxFrameDroppedError |
+		     MaskTxFifoError, fp->this_card_priv);
+
+	{
+		uint8_t __iomem *ioaddr = (uint8_t __iomem *)dev->base_addr;
+
+		/* Start Rx and Tx channels. */
+		writel(Receive_enable |
+		       (Rx_fifo_threshold & RX_FIFO_THRESHOLD_PACKET_MODE),
+		       ioaddr + fp->reg_rxctrl);
+
+		writel((Transmit_enable |
+			(Tx_desc_threshold &
+			 (TX_DESC_THRESHOLD_PACKET_MODE << 8)) |
+			(Tx_fifo_threshold & TX_FIFO_THRESHOLD_PACKET_MODE)),
+		       ioaddr + fp->reg_txctrl);
+	}
+
+	netif_wake_queue(dev);
+
+	init_timer(&fp->timer);
+	fp->timer.expires = jiffies + HZ;
+	fp->timer.data = (unsigned long)dev;
+	fp->timer.function = &fepci_timer;
+	add_timer(&fp->timer);
+
+	return 0;
+}
+
+static int fepci_open(struct net_device *dev)
+{
+	struct fepci_ch_private *fp = netdev_priv(dev);
+	if (unlikely(fp->in_stream_mode))
+		fepci_stream_close_down(dev, fp);
+	return fepci_open_down(dev, fp);
+}
+
+static void fepci_timer(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct fepci_ch_private *fp = netdev_priv(dev);
+
+	if ((get_common_reg_word(fp->this_card_priv->ioaddr, 0x72) >>
+	     fp->channel_number) & 1)
+		netif_carrier_off(dev);
+	else
+		netif_carrier_on(dev);
+
+	if (fp->in_eth_mode)
+		mod_timer(&fp->timer, jiffies + 5 * HZ);
+}
+
+static void fepci_tx_timeout(struct net_device *dev)
+{
+	struct fepci_ch_private *fp = netdev_priv(dev);
+	tasklet_schedule(&fp->transmission);
+}
+
+/* Initialize the reception and transmission ring buffers. */
+static void fepci_init_ring(struct net_device *dev)
+{
+	struct fepci_ch_private *fp = netdev_priv(dev);
+	unsigned i;
+
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		struct sk_buff *skb = __netdev_alloc_skb(dev,
+							 RETINA_DMA_SIZE +
+							 NET_IP_ALIGN,
+							 GFP_KERNEL);
+		if (unlikely(skb == NULL)) {
+ZERO:
+			writel(0, &fp->rx_desc[i].desc_a);
+			writel(0, &fp->rx_desc[i].desc_b);
+		} else {
+			dma_addr_t bus_address;
+			skb_reserve(skb, NET_IP_ALIGN);
+			bus_address =
+				pci_map_single(fp->this_card_priv->pci_dev,
+						skb->data, RETINA_MRU,
+						PCI_DMA_FROMDEVICE);
+			if (likely(!pci_dma_mapping_error(bus_address))) {
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+				fp->rx[i].skbuff = skb;
+				pci_unmap_addr_set(fp->rx + i, address,
+						   bus_address);
+				writel(bus_address, &fp->rx_desc[i].desc_a);
+				writel(enable_transfer, &fp->rx_desc[i].desc_b);
+			} else {
+				dev_kfree_skb(skb);
+				goto ZERO;
+			}
+		}
+	}
+
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		fp->tx[i].skbuff = NULL;
+		writel(0, &fp->tx_desc[i].desc_a); /* No address. */
+		/* No transfer enable, no interrupt enable. */
+		writel(0, &fp->tx_desc[i].desc_b);
+	}
+}
+
+static int fepci_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct fepci_ch_private *fp;
+	unsigned cur_tx;
+	unsigned next;
+	unsigned tx_length;
+	dma_addr_t bus_address;
+
+	if (unlikely(skb_padto(skb, ETH_ZLEN)))
+		return NETDEV_TX_OK;
+	tx_length = skb->len;
+	fp = netdev_priv(dev);
+	bus_address = pci_map_single(fp->this_card_priv->pci_dev, skb->data,
+				     tx_length, PCI_DMA_TODEVICE);
+	cur_tx = fp->cur_tx;
+	if (likely(!pci_dma_mapping_error(bus_address))) {
+		struct fepci_desc __iomem *descriptor;
+		pci_unmap_addr_set(fp->tx + cur_tx, address, bus_address);
+		descriptor = &fp->tx_desc[cur_tx];
+		writel(bus_address, &descriptor->desc_a);
+		writel((tx_length & frame_length) | enable_transfer,
+		       &descriptor->desc_b);
+	} else {
+		return NETDEV_TX_BUSY;
+	}
+	fp->stats.tx_bytes += tx_length;
+
+	fp->tx[cur_tx].skbuff = skb;
+
+	/* Calculate the next transmission descriptor entry. */
+	next = (cur_tx + 1) & (TX_RING_SIZE - 1);
+	fp->cur_tx = next;
+	/* If the next descriptor is busy, discontinue taking new ones. */
+	if (fp->tx[next].skbuff != NULL)
+		netif_stop_queue(dev);
+	dev->trans_start = jiffies;
+
+	return NETDEV_TX_OK;
+}
+
+static void retina_tx(unsigned long channel)
+{
+	unsigned next;
+	struct fepci_ch_private *fp = (struct fepci_ch_private *)channel;
+	struct net_device *dev;
+	struct fepci_desc __iomem *tx_desc = fp->tx_desc;
+	unsigned i = 0;
+	do {
+		uint32_t desc_b;
+		struct sk_buff *skb = fp->tx[i].skbuff;
+		struct fepci_desc __iomem *desc;
+		if (skb == NULL)
+			continue;
+		desc = tx_desc + i;
+		desc_b = readl_relaxed(&desc->desc_b);
+		if ((desc_b & transfer_not_done) == 0) {
+			/* Has been sent. */
+			pci_unmap_single(fp->this_card_priv->pci_dev,
+					 pci_unmap_addr(fp->tx + i, address),
+					 skb->len, PCI_DMA_TODEVICE);
+			dev_kfree_skb(skb);
+			fp->tx[i].skbuff = NULL;
+			if (unlikely(desc_b & fifo_error))
+				fp->stats.tx_fifo_errors++;
+			else
+				fp->stats.tx_packets++;
+		}
+	} while (i++ < TX_RING_SIZE - 1);
+	dev = fp->this_dev;
+	netif_tx_lock(dev);
+	next = fp->cur_tx;
+	/* If next transmission descriptor is free, continue taking new ones. */
+	if (netif_queue_stopped(dev) &&
+	    fp->tx[next].skbuff == NULL &&
+	    fp->in_eth_mode)
+		netif_wake_queue(dev);
+	netif_tx_unlock(dev);
+}
+
+static inline void fepci_rx(struct fepci_ch_private *fp, struct
net_device *dev)
+{
+	unsigned i, old_cur_rx = fp->cur_rx;
+	unsigned last = (old_cur_rx + RX_RING_SIZE - 1) & (RX_RING_SIZE - 1);
+	for (i = old_cur_rx;
+	     i != last;
+	     i = (i + 1) & (RX_RING_SIZE - 1)) {
+		uint32_t desc_b;
+		struct sk_buff **rx_skbuff = &fp->rx[i].skbuff;
+		struct sk_buff *skb = *rx_skbuff;
+		struct fepci_desc __iomem *rx_desc = fp->rx_desc + i;
+		if (unlikely(skb == NULL))
+			goto RESERVE;
+		desc_b = readl(&rx_desc->desc_b);
+		if (!(desc_b & transfer_not_done)) { /* transfer done */
+			fp->cur_rx = (i + 1) & (RX_RING_SIZE - 1);
+			if (unlikely(desc_b & (fifo_error | size_error |
+					       crc_error | octet_error |
+					       line_error))) {
+				if (desc_b & fifo_error)
+					fp->stats.rx_frame_errors++;
+				else if (desc_b & size_error)
+					fp->stats.rx_over_errors++;
+				else if (desc_b & crc_error)
+					fp->stats.rx_crc_errors++;
+ENABLE_TRANSFER:		writel(enable_transfer, &rx_desc->desc_b);
+				fp->stats.rx_errors++;
+				continue;
+			} else {
+				uint32_t length = (desc_b & frame_length) - 4;
+				if (unlikely(length > RETINA_MRU)) {
+					fp->stats.rx_length_errors++;
+					goto ENABLE_TRANSFER;
+				}
+				pci_unmap_single(fp->this_card_priv->pci_dev,
+					pci_unmap_addr(fp->rx + i, address),
+					RETINA_MRU, PCI_DMA_FROMDEVICE);
+				__skb_put(skb, length);
+				skb->protocol = eth_type_trans(skb, dev);
+				if (dev->flags & IFF_POINTOPOINT) {
+					/* Everything received is for us. */
+					if (dev->flags & IFF_NOARP) {
+						/* NOARP applied ->
+						 * destination MAC addresses
+						 * are bogus. */
+						if (skb->pkt_type ==
+						    PACKET_OTHERHOST)
+							skb->pkt_type =
+								PACKET_HOST;
+					} else {
+						/* NOARP not applied ->
+						 * destination MAC addresses are
+						 * broadcast. */
+						if (skb->pkt_type ==
+						    PACKET_BROADCAST)
+							skb->pkt_type =
+								PACKET_HOST;
+					}	/* IFF_NOARP */
+				}	/* IFF_POINTOPOINT */
+				netif_rx(skb);
+				fp->stats.rx_bytes += length;
+				fp->stats.rx_packets++;
+				dev->last_rx = jiffies;
+			}
+			/* reserve a new one */
+RESERVE:		skb = netdev_alloc_skb(dev, RETINA_DMA_SIZE +
+						    NET_IP_ALIGN);
+			if (unlikely(skb == NULL)) {
+				*rx_skbuff = NULL;
+				continue;	/* Better luck next round. */
+			} else {
+				dma_addr_t address;
+				skb_reserve(skb, NET_IP_ALIGN);
+				address = pci_map_single(fp->this_card_priv->
+							 pci_dev, skb->data,
+							 RETINA_MRU,
+							 PCI_DMA_FROMDEVICE);
+				if (likely(!pci_dma_mapping_error(address))) {
+					pci_unmap_addr_set(fp->rx + i,
+							   address, address);
+					*rx_skbuff = skb;
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
+					writel(address, &rx_desc->desc_a);
+					writel(enable_transfer,
+					       &rx_desc->desc_b);
+				} else {
+					*rx_skbuff = NULL;
+					dev_kfree_skb_irq(skb);
+					dev_warn(&dev->dev,
+						 "failed to map DMA\n");
+				}
+			}
+		}
+	}
+}
+
+static irqreturn_t fepci_interrupt(int irq, void *dev_instance)
+{
+	struct net_device *dev = dev_instance;
+	uint8_t __iomem *ioaddr = (uint8_t __iomem *)dev->base_addr;
+	struct fepci_ch_private *fp = netdev_priv(dev);
+	const unsigned char channel = fp->channel_number;
+	const uint32_t intr_status = get_int_status(channel, ioaddr);
+
+	if (!intr_status)
+		return IRQ_NONE;
+	clear_int(channel, intr_status, ioaddr);
+
+	if (intr_status &
+		(IntrFrameReceived | IntrRxFifoError | IntrRxFrameDroppedError))
+		fepci_rx(fp, dev);
+	if (intr_status & IntrFrameTransmitted)
+		tasklet_schedule(&fp->transmission);
+	return IRQ_HANDLED;
+}
+
+static void fepci_close_down(struct net_device *dev,
+			     struct fepci_ch_private *fp,
+			     struct fepci_card_private *card)
+{
+	unsigned i;
+	uint8_t __iomem *ioaddr;
+	struct pci_dev *pdev;
+	if (unlikely(!fp->in_eth_mode))
+		return;
+	/* Disable interrupts by clearing the interrupt mask. */
+	set_int_mask(fp->channel_number, 0x0, card);
+
+	/* Stop the transmission and reception processes. */
+	ioaddr = (uint8_t __iomem *)dev->base_addr;
+	writel(0x0, ioaddr + fp->reg_rxctrl);
+	writel(0x0, ioaddr + fp->reg_txctrl);
+	fp->in_eth_mode = 0;
+	smp_wmb(); /* Get out of Ethernet mode before deleting the timer. */
+	del_timer_sync(&fp->timer);
+
+	free_irq(dev->irq, dev);
+
+	tasklet_kill(&fp->transmission);
+	netif_tx_disable(dev);
+	pdev = card->pci_dev;
+	/* Free all the reception struct sk_buffs... */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		struct sk_buff *skb = fp->rx[i].skbuff;
+		if (skb != NULL) {
+			pci_unmap_single(pdev,
+					 pci_unmap_addr(fp->rx + i, address),
+					 RETINA_MRU, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(skb);
+			fp->rx[i].skbuff = NULL;
+		}
+	}
+	/* ...and transmission ones. */
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		struct sk_buff *skb = fp->tx[i].skbuff;
+		if (skb != NULL) {
+			pci_unmap_single(pdev,
+					 pci_unmap_addr(fp->tx + i, address),
+					 skb->len, PCI_DMA_TODEVICE);
+			dev_kfree_skb(skb);
+			fp->tx[i].skbuff = NULL;
+		}
+	}
+}
+
+static int fepci_close(struct net_device *dev)
+{
+	struct fepci_ch_private *fp = netdev_priv(dev);
+	struct fepci_card_private *card = fp->this_card_priv;
+	if (unlikely(!netif_device_present(dev)))
+		return -ENODEV;
+	fepci_close_down(dev, fp, card);
+	return 0;
+}
+
+static struct net_device_stats *fepci_get_stats(struct net_device *dev)
+{
+	struct fepci_ch_private *fp = netdev_priv(dev);
+	return &fp->stats;
+}
+
+static void set_rx_mode(struct net_device *dev)
+{
+	dev_dbg(&dev->dev, "set_rx_mode\n");
+}
+
+static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct fepci_ch_private *fp = netdev_priv(dev);
+
+	dev_dbg(&dev->dev, "netdev_ioctl called (command_nmbr:0x%x)\n", cmd);
+
+	switch (cmd) {
+	case FEPCI_NETDEV_IOCTL_STREAM_BUFSIZE:
+	{
+		unsigned data = ((unsigned long)rq->ifr_data) & 0xff;
+		dev_dbg(&dev->dev,
+			"ioctl stream bufsize commanded. (bufsize:0x%x)\n",
+			data);
+		if (fp->in_stream_mode)
+			return -EBUSY;
+		fp->bufsize_order = data;
+		break;
+	}
+	case FEPCI_NETDEV_IOCTL_STREAM_UNITSIZE:
+	{
+		unsigned data = ((unsigned long)rq->ifr_data) & 0xff;
+		dev_dbg(&dev->dev,
+			"ioctl stream unitsize commanded. (unitsize:0x%x)\n",
+			data);
+		if (fp->in_stream_mode)
+			return -EBUSY;
+		fp->fake_unit_sz_order = data;
+		break;
+	}
+	case FEPCI_NETDEV_IOCTL_STREAM_OPEN:
+	dev_dbg(&dev->dev, "ioctl stream open commanded\n");
+	return fepci_stream_open_down(dev, fp);
+	case FEPCI_NETDEV_IOCTL_STREAM_START:
+	dev_dbg(&dev->dev, "ioctl stream start commanded\n");
+	return fepci_stream_start_down(dev, fp);
+	case FEPCI_NETDEV_IOCTL_STREAM_CLOSE:
+	dev_dbg(&dev->dev, "ioctl stream close commanded\n");
+	return fepci_stream_close_down(dev, fp);
+	default:
+	dev_dbg(&dev->dev, "unknown ioctl command 0x%x\n", cmd);
+	return -ENOTTY;
+	}
+	return 0;
+}
+
+static void alarm_off(uint8_t __iomem *ioaddr, unsigned int irq)
+{
+	uint8_t __iomem *ioaddr_reg_custom = ioaddr + reg_custom;
+	do {
+		/* Alarm manager interrupt off. */
+		writel(0, ioaddr_reg_custom);
+		synchronize_irq(irq);
+	} while (readl_relaxed(ioaddr_reg_custom) & AM_interrupt_mask);
+}
+
+static void fepci_remove_one(struct pci_dev *pdev)
+{
+	struct fepci_card_private *cardp = pci_get_drvdata(pdev);
+	unsigned int i;
+	uint8_t __iomem *ioaddr = cardp->ioaddr;
+	unsigned int irq = pdev->irq;
+
+	alarm_off(ioaddr, irq);
+
+	for (i = 0; i < CHANNELS; i++) {
+		struct fepci_ch_private *fp = cardp->ch_privates[i];
+		struct net_device *dev = fp->this_dev;
+		if (unlikely(dev == NULL))
+			continue;
+		unregister_netdev(dev);
+		fepci_stream_close_down(dev, fp);
+		free_netdev(dev);
+		cardp->ch_privates[i] = NULL;
+	}
+	del_timer_sync(&cardp->mailbox_timer);
+	free_irq(irq, cardp);
+
+	pci_set_drvdata(pdev, NULL);
+
+	if (cardp->card_number + 1 == find_cnt)
+		find_cnt--;
+	cardp->pci_dev = NULL;
+
+	iounmap(ioaddr);
+
+	pci_disable_device(pdev);
+	pci_release_regions(pdev);
+}
+
+#ifdef CONFIG_PM
+static int fepci_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct fepci_card_private *cardp = pci_get_drvdata(pdev);
+	unsigned channel;
+	unsigned irq = pdev->irq;
+	channel = 0;
+	do {
+		struct fepci_ch_private *fp = cardp->ch_privates[channel];
+		struct net_device *dev = fp->this_dev;
+		bool in_eth_mode;
+		bool in_stream_mode;
+		bool stream_on;
+		if (unlikely(dev == NULL))
+			continue;
+		netif_device_detach(dev);
+		in_eth_mode = fp->in_eth_mode;
+		in_stream_mode = fp->in_stream_mode;
+		stream_on = fp->stream_on;
+		rtnl_lock();
+		if (in_eth_mode)
+			fepci_close_down(fp->this_dev, fp, cardp);
+		else if (in_stream_mode)
+			fepci_stream_close_down(dev, fp);
+		rtnl_unlock();
+		fp->in_eth_mode = in_eth_mode;
+		fp->in_stream_mode = in_stream_mode;
+		fp->stream_on = stream_on;
+	} while (channel++ < CHANNELS - 1);
+	if (del_timer_sync(&cardp->mailbox_timer))
+		fepci_mailbox_timer((unsigned long)cardp);
+	alarm_off(cardp->ioaddr, irq);
+	/* Disable IRQ */
+	free_irq(irq, cardp);
+	cardp->pci_dev = NULL;
+	pci_save_state(pdev);
+	/* Disable IO/bus master/irq router */
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	return 0;
+}
+
+static int fepci_resume(struct pci_dev *pdev)
+{
+	struct fepci_card_private *cardp = pci_get_drvdata(pdev);
+	unsigned channel;
+	int error;
+	unsigned irq;
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	/* Device's IRQ possibly is changed, driver should take care. */
+	error = pci_enable_device(pdev);
+	if (unlikely(error))
+		return error;
+	pci_set_master(pdev);
+	/* Driver specific operations. */
+	irq = pdev->irq;
+	cardp->pci_dev = pdev;
+	error = request_irq(pdev->irq, &alarm_manager_interrupt,
+			    IRQF_SHARED, fepci_alarm_manager_name, cardp);
+	if (unlikely(error))
+		return error;
+	/* Alarm manager interrupt on. */
+	writel(AM_interrupt_mask, cardp->ioaddr + reg_custom);
+	channel = 0;
+	do {
+		struct fepci_ch_private *fp = cardp->ch_privates[channel];
+		struct net_device *dev = fp->this_dev;
+		if (unlikely(dev == NULL))
+			continue;
+		dev->irq = irq;
+		rtnl_lock();
+		if (fp->in_eth_mode) {
+			int open = fepci_open_down(dev, fp);
+			if (unlikely(open))
+				error = open;
+		} else if (fp->in_stream_mode) {
+			int open;
+			fp->in_stream_mode = 0;
+			open = fepci_stream_open_down(dev, fp);
+			if (unlikely(open))
+				error = open;
+			if (fp->stream_on) {
+				fp->stream_on = 0;
+				open = fepci_stream_start_down(dev, fp);
+				if (unlikely(open))
+					error = open;
+			}
+		}
+		rtnl_unlock();
+		netif_device_attach(dev);
+	} while (channel++ < CHANNELS - 1);
+	return error;
+}
+#endif
+
+static struct pci_driver fepci_driver = {
+	.name		= "retina",
+	.id_table	= fepci_pci_tbl,
+	.probe		= fepci_init_one,
+	.remove		= fepci_remove_one,
+#ifdef CONFIG_PM
+	.suspend	= fepci_suspend,
+	.resume		= fepci_resume
+#endif
+};
+
+static int __init fepci_init(void)
+{
+	stream_pointers = get_zeroed_page(GFP_KERNEL);
+	if (unlikely(stream_pointers == 0))
+		return -ENOMEM;
+	SetPageReserved(virt_to_page(stream_pointers));
+	major = pci_register_driver(&fepci_driver);
+	if (unlikely(major))
+		goto CLEAR;
+	major = fepci_register_char_device();
+	if (unlikely(major < 0)) {
+		pci_unregister_driver(&fepci_driver);
+CLEAR:
+		ClearPageReserved(virt_to_page(stream_pointers));
+		free_page(stream_pointers);
+		return major;
+	}
+	return 0;
+}
+
+static void __exit fepci_cleanup(void)
+{
+	pci_unregister_driver(&fepci_driver);
+	fepci_unregister_char_device();
+	ClearPageReserved(virt_to_page(stream_pointers));
+	free_page(stream_pointers);
+}
+
+module_init(fepci_init);
+module_exit(fepci_cleanup);
--- next-20080519/drivers/net/wan/Kconfig	2008-05-19 09:34:27.000000000 +0300
+++ next/drivers/net/wan/Kconfig	2008-05-28 12:46:50.789832565 +0300
@@ -496,4 +496,15 @@ config SBNI_MULTILINE

 	  If unsure, say N.

+config RETINA
+	tristate "Retina support"
+	depends on PCI
+	help
+	  Driver for Retina C5400 and E2200 network PCI cards, which
+	  support G.703, G.SHDSL with Ethernet encapsulation or
+	  raw character device for pseudowire.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called retina.
+
 endif # WAN
--- next-20080519/drivers/net/wan/Makefile	2008-05-19 09:34:27.000000000 +0300
+++ next/drivers/net/wan/Makefile	2008-05-28 12:44:58.771277746 +0300
@@ -42,6 +42,7 @@ obj-$(CONFIG_C101)		+= c101.o
 obj-$(CONFIG_WANXL)		+= wanxl.o
 obj-$(CONFIG_PCI200SYN)		+= pci200syn.o
 obj-$(CONFIG_PC300TOO)		+= pc300too.o
+obj-$(CONFIG_RETINA)		+= retina.o

 clean-files := wanxlfw.inc
 $(obj)/wanxl.o:	$(obj)/wanxlfw.inc
