From: Tadashi Abe <tabe@mvista.com>
Subject: [PATCH] pegasus: fix USB device ID for ETX-US2
Date: Mon, 17 May 2010 17:19:40 +0900
Message-ID: <4BF0FC1C.2020408@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:65419 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab0EQITo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 04:19:44 -0400
Received: by pxi5 with SMTP id 5so2406783pxi.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 01:19:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

USB device ID definition for I-O Data ETX-US2 is wrong.
Correct ID is 0x093a. Here's snippet from /proc/bus/usb/devices;

T:  Bus=01 Lev=01 Prnt=01 Port=01 Cnt=01 Dev#=  2 Spd=480 MxCh= 0
D:  Ver= 2.00 Cls=ff(vend.) Sub=ff Prot=00 MxPS=64 #Cfgs=  1
P:  Vendor=04bb ProdID=093a Rev= 1.01
S:  Manufacturer=I-O DATA DEVICE,INC.
S:  Product=I-O DATA ETX2-US2
S:  SerialNumber=A26427
C:* #Ifs= 1 Cfg#= 1 Atr=80 MxPwr=224mA
I:* If#= 0 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=ff Prot=00 Driver=pegasus
E:  Ad=81(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=02(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=83(I) Atr=03(Int.) MxPS=   8 Ivl=125us

This patch enables pegasus driver to work fine with ETX-US2.

Signed-off-by: Tadashi Abe <tabe@mvista.com>
---
diff --git a/drivers/net/usb/pegasus.h b/drivers/net/usb/pegasus.h
index b90d876..29f5211 100644
--- a/drivers/net/usb/pegasus.h
+++ b/drivers/net/usb/pegasus.h
@@ -256,7 +256,7 @@ PEGASUS_DEV( "IO DATA USB ET/TX", VENDOR_IODATA, 0x0904,
 		DEFAULT_GPIO_RESET )
 PEGASUS_DEV( "IO DATA USB ET/TX-S", VENDOR_IODATA, 0x0913,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
-PEGASUS_DEV( "IO DATA USB ETX-US2", VENDOR_IODATA, 0x092a,
+PEGASUS_DEV( "IO DATA USB ETX-US2", VENDOR_IODATA, 0x093a,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Kingston KNU101TX Ethernet", VENDOR_KINGSTON, 0x000a,
 		DEFAULT_GPIO_RESET)
