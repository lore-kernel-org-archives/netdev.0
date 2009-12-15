From: Alexander Strakh <strakh@ispras.ru>
Subject: BUG null dreference in driver drivers/net/hamradio/bpqether.c
Date: Tue, 15 Dec 2009 17:55:09 +0000
Message-ID: <200912151755.09515.strakh@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	KERNEL_VERSION: 2.6.32
	SUBJECT: null derefernce in function  bpq_xmit
	SUBSCRIBE:
	In driver drivers/net/hamradio/bpqether.c in function bpq_xmit:

1. if in line 288 after calling function bpq_get_ether_dev variable dev = 
NULL, then we goto line 289
2. In line 289:  null dereference of dev - "dev->stats.tx_dropped++"

 288        if ((dev = bpq_get_ether_dev(dev)) == NULL) {
 289                dev->stats.tx_dropped++;
 290                kfree_skb(skb);
 291                return NETDEV_TX_OK;
 292        }

Found by Linux Device Drivers Verification Project (Svace Detector)
