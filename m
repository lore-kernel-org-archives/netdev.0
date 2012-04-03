From: Mike Sinkovsky <msink@permonline.ru>
Subject: [PATCH v6 0/2] Ethernet drivers for WIZnet chips
Date: Tue,  3 Apr 2012 16:58:44 +0600
Message-ID: <1333450726-24455-1-git-send-email-msink@permonline.ru>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru>
Cc: Mike Sinkovsky <msink@permonline.ru>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332752876-1650-1-git-send-email-msink@permonline.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on original driver from chip manufacturer, but nearly full rewite.
Tested and used in production with Blackfin BF531 embedded processor.

Signed-off-by: Mike Sinkovsky <msink@permonline.ru>
---
v6:
 - remove (S0_TX_FSR < skb->len) check in TX handler, it doesn't work
   anyway. Chip can transmit only one frame with MTU 1500 at a time,
   and tx buffer size is bigger.
 - remove dependency (ARM || BLACKFIN) - should work on any arch
 - interrupt handler returns IRQ_NONE if status register is zero
 - use devm_request_threaded_irq for request detect_link handler
 - remove dev_info if probe failed
v5:
 - added driver for WIZnet W5100
 - disabled VLAN (NETIF_F_VLAN_CHALLENGED)
v4:
 - netif_stop_queue if tx fifo is full, netif_wake_queue in interrupt
 - use netif_info macro
v3:
 - reading macaddr from platform_data
 - ethtool: get_link, get_msglevel, set_msglevel
 - more cleanups
v2:
 - corrected handling of NET_ADDR_RANDOM flag
 - support for WIZNET_BUS_ANY mode
 - link detection using gpio
 - registers read using ethtool
 - more cleanups
