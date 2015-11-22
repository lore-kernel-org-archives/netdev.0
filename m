From: Mauro Dreissig <mukadr@gmail.com>
Subject: [PATCH] staging: rtl8712: Cleanup _io_ops wrappers
Date: Sun, 22 Nov 2015 20:02:19 -0200
Message-ID: <56523B6B.1050800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	mukadr@gmail.com
To: Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
	gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34874 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbbKVWC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 17:02:27 -0500
Received: by qkao63 with SMTP id o63so52468827qka.2
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2015 14:02:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes ugly and unnecessary declarations.

Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
---
 drivers/staging/rtl8712/rtl8712_io.c | 77 +++++++++++-------------------------
 1 file changed, 22 insertions(+), 55 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl8712_io.c b/drivers/staging/rtl8712/rtl8712_io.c
index 4148d48..391eff3 100644
--- a/drivers/staging/rtl8712/rtl8712_io.c
+++ b/drivers/staging/rtl8712/rtl8712_io.c
@@ -36,109 +36,76 @@
 
 u8 r8712_read8(struct _adapter *adapter, u32 addr)
 {
-	struct io_queue *pio_queue = adapter->pio_queue;
-	struct intf_hdl *pintfhdl = &(pio_queue->intf);
-	u8 (*_read8)(struct intf_hdl *pintfhdl, u32 addr);
+	struct intf_hdl *hdl = &adapter->pio_queue->intf;
 
-	_read8 = pintfhdl->io_ops._read8;
-	return  _read8(pintfhdl, addr);
+	return hdl->io_ops._read8(hdl, addr);
 }
 
 u16 r8712_read16(struct _adapter *adapter, u32 addr)
 {
-	struct io_queue *pio_queue = adapter->pio_queue;
-	struct intf_hdl *pintfhdl = &(pio_queue->intf);
-	u16 (*_read16)(struct intf_hdl *pintfhdl, u32 addr);
+	struct intf_hdl *hdl = &adapter->pio_queue->intf;
 
-	_read16 = pintfhdl->io_ops._read16;
-	return _read16(pintfhdl, addr);
+	return hdl->io_ops._read16(hdl, addr);
 }
 
 u32 r8712_read32(struct _adapter *adapter, u32 addr)
 {
-	struct io_queue *pio_queue = adapter->pio_queue;
-	struct intf_hdl *pintfhdl = &(pio_queue->intf);
-	u32 (*_read32)(struct intf_hdl *pintfhdl, u32 addr);
+	struct intf_hdl *hdl = &adapter->pio_queue->intf;
 
-	_read32 = pintfhdl->io_ops._read32;
-	return _read32(pintfhdl, addr);
+	return hdl->io_ops._read32(hdl, addr);
 }
 
 void r8712_write8(struct _adapter *adapter, u32 addr, u8 val)
 {
-	struct io_queue *pio_queue = adapter->pio_queue;
-	struct intf_hdl *pintfhdl = &(pio_queue->intf);
-	void (*_write8)(struct intf_hdl *pintfhdl, u32 addr, u8 val);
+	struct intf_hdl *hdl = &adapter->pio_queue->intf;
 
-	_write8 = pintfhdl->io_ops._write8;
-	_write8(pintfhdl, addr, val);
+	hdl->io_ops._write8(hdl, addr, val);
 }
 
 void r8712_write16(struct _adapter *adapter, u32 addr, u16 val)
 {
-	struct io_queue *pio_queue = adapter->pio_queue;
-	struct intf_hdl *pintfhdl = &(pio_queue->intf);
-	void (*_write16)(struct intf_hdl *pintfhdl, u32 addr, u16 val);
+	struct intf_hdl *hdl = &adapter->pio_queue->intf;
 
-	_write16 = pintfhdl->io_ops._write16;
-	_write16(pintfhdl, addr, val);
+	hdl->io_ops._write16(hdl, addr, val);
 }
 
 void r8712_write32(struct _adapter *adapter, u32 addr, u32 val)
 {
-	struct io_queue *pio_queue = adapter->pio_queue;
-	struct intf_hdl *pintfhdl  = &(pio_queue->intf);
+	struct intf_hdl *hdl = &adapter->pio_queue->intf;
 
-	void (*_write32)(struct intf_hdl *pintfhdl, u32 addr, u32 val);
-
-	_write32 = pintfhdl->io_ops._write32;
-	_write32(pintfhdl, addr, val);
+	hdl->io_ops._write32(hdl, addr, val);
 }
 
 void r8712_read_mem(struct _adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
 {
-	struct io_queue *pio_queue = adapter->pio_queue;
-	struct intf_hdl *pintfhdl = &(pio_queue->intf);
+	struct intf_hdl *hdl = &adapter->pio_queue->intf;
 
-	void (*_read_mem)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt,
-			  u8 *pmem);
 	if (adapter->bDriverStopped || adapter->bSurpriseRemoved)
 		return;
-	_read_mem = pintfhdl->io_ops._read_mem;
-	_read_mem(pintfhdl, addr, cnt, pmem);
+
+	hdl->io_ops._read_mem(hdl, addr, cnt, pmem);
 }
 
 void r8712_write_mem(struct _adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
 {
-	struct io_queue *pio_queue = adapter->pio_queue;
-	struct intf_hdl *pintfhdl = &(pio_queue->intf);
-	void (*_write_mem)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt,
-			   u8 *pmem);
+	struct intf_hdl *hdl = &adapter->pio_queue->intf;
 
-	_write_mem = pintfhdl->io_ops._write_mem;
-	_write_mem(pintfhdl, addr, cnt, pmem);
+	hdl->io_ops._write_mem(hdl, addr, cnt, pmem);
 }
 
 void r8712_read_port(struct _adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
 {
-	struct io_queue *pio_queue = adapter->pio_queue;
-	struct intf_hdl	*pintfhdl = &(pio_queue->intf);
+	struct intf_hdl *hdl = &adapter->pio_queue->intf;
 
-	u32 (*_read_port)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt,
-			  u8 *pmem);
 	if (adapter->bDriverStopped || adapter->bSurpriseRemoved)
 		return;
-	_read_port = pintfhdl->io_ops._read_port;
-	_read_port(pintfhdl, addr, cnt, pmem);
+
+	hdl->io_ops._read_port(hdl, addr, cnt, pmem);
 }
 
 void r8712_write_port(struct _adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
 {
-	struct io_queue *pio_queue = adapter->pio_queue;
-	struct intf_hdl *pintfhdl = &(pio_queue->intf);
+	struct intf_hdl *hdl = &adapter->pio_queue->intf;
 
-	u32 (*_write_port)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt,
-			   u8 *pmem);
-	_write_port = pintfhdl->io_ops._write_port;
-	_write_port(pintfhdl, addr, cnt, pmem);
+	hdl->io_ops._write_port(hdl, addr, cnt, pmem);
 }
-- 
1.9.1
