From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH] r8169 cleanup
Date: Fri, 10 Sep 2004 16:59:00 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409101659.00322.jdmason@us.ltcfwd.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removal of unnecessary code.  

In the first part, the double not is not necessary.  In the second part, Tx 
timeouts are already logged and this line is not needed.  Finally, a bit of 
code beautification (though it may only be for my eyes).

Thanks,
Jon

--- /usr/src/linux-2.6.9-rc1-mm4/drivers/net/r8169.c    2004-09-10 
11:16:57.535521016 -0500
+++ r8169.c     2004-09-10 16:06:49.398539048 -0500
@@ -654,7 +654,7 @@ static u32 rtl8169_get_rx_csum(struct ne
 {
        struct rtl8169_private *tp = netdev_priv(dev);

-       return !!(tp->cp_cmd & RxChkSum);
+       return (tp->cp_cmd & RxChkSum);
 }

 static int rtl8169_set_rx_csum(struct net_device *dev,  u32 data)
@@ -1694,7 +1694,6 @@ rtl8169_tx_timeout(struct net_device *de
        void *ioaddr = tp->mmio_addr;
        u8 tmp8;

-       printk(KERN_INFO "%s: TX Timeout\n", dev->name);
        /* disable Tx, if not already */
        tmp8 = RTL_R8(ChipCmd);
        if (tmp8 & CmdTxEnb)
@@ -1779,8 +1778,7 @@ static int rtl8169_start_xmit(struct sk_
        struct TxDesc *txd = tp->TxDescArray + entry;
        void *ioaddr = tp->mmio_addr;
        dma_addr_t mapping;
-       u32 status, len;
-       u32 opts1;
+       u32 status, len, opts1;
        int ret = 0;

        if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
