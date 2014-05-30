From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 8/8] net: cdc_ncm: document the sysfs API
Date: Fri, 30 May 2014 09:31:10 +0200
Message-ID: <1401435070-26721-9-git-send-email-bjorn@mork.no>
References: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Lars Melin <larsm17@gmail.com>, Peter Stuge <peter@stuge.se>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51788 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932093AbaE3HdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 03:33:13 -0400
In-Reply-To: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding documentation for all the driver specific sysfs attributes.

Cc: Peter Stuge <peter@stuge.se>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 Documentation/ABI/testing/sysfs-class-net-cdc_ncm | 149 ++++++++++++++=
++++++++
 1 file changed, 149 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-cdc_ncm

diff --git a/Documentation/ABI/testing/sysfs-class-net-cdc_ncm b/Docume=
ntation/ABI/testing/sysfs-class-net-cdc_ncm
new file mode 100644
index 000000000000..5cedf72df358
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net-cdc_ncm
@@ -0,0 +1,149 @@
+What:		/sys/class/net/<iface>/cdc_ncm/min_tx_pkt
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		The driver will pad NCM Transfer Blocks (NTBs) longer
+		than this to tx_max, allowing the device to receive
+		tx_max sized frames with no terminating short
+		packet. NTBs shorter than this limit are transmitted
+		as-is, without any padding, and are terminated with a
+		short USB packet.
+
+		Padding to tx_max allows the driver to transmit NTBs
+		back-to-back without any interleaving short USB
+		packets.  This reduces the number of short packet
+		interrupts in the device, and represents a tradeoff
+		between USB bus bandwidth and device DMA optimization.
+
+		Set to 0 to pad all frames. Set greater than tx_max to
+		disable all padding.
+
+What:		/sys/class/net/<iface>/cdc_ncm/rx_max
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		The maximum NTB size for RX.  Cannot exceed the
+		maximum value supported by the device. Must allow at
+		least one max sized datagram plus headers.
+
+		The actual limits are device dependent.  See
+		dwNtbInMaxSize.
+
+		Note: Some devices will silently ignore changes to
+		this value, resulting in oversized NTBs and
+		corresponding framing errors.
+
+What:		/sys/class/net/<iface>/cdc_ncm/tx_max
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		The maximum NTB size for TX.  Cannot exceed the
+		maximum value supported by the device.  Must allow at
+		least one max sized datagram plus headers.
+
+		The actual limits are device dependent.  See
+		dwNtbOutMaxSize.
+
+What:		/sys/class/net/<iface>/cdc_ncm/tx_timer_usecs
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		Datagram aggregation timeout in =C2=B5s. The driver will
+		wait up to 3 times this timeout for more datagrams to
+		aggregate before transmitting an NTB frame.
+
+		Valid range: 5 to 4000000
+
+		Set to 0 to disable aggregation.
+
+The following read-only attributes all represent fields of the
+structure defined in section 6.2.1 "GetNtbParameters" of "Universal
+Serial Bus Communications Class Subclass Specifications for Network
+Control Model Devices" (CDC NCM), Revision 1.0 (Errata 1), November
+24, 2010 from USB Implementers Forum, Inc.  The descriptions are
+quoted from table 6-3 of CDC NCM: "NTB Parameter Structure".
+
+What:		/sys/class/net/<iface>/cdc_ncm/bmNtbFormatsSupported
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		Bit 0: 16-bit NTB supported (set to 1)
+		Bit 1: 32-bit NTB supported
+		Bits 2 =E2=80=93 15: reserved (reset to zero; must be ignored by hos=
t)
+
+What:		/sys/class/net/<iface>/cdc_ncm/dwNtbInMaxSize
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		IN NTB Maximum Size in bytes
+
+What:		/sys/class/net/<iface>/cdc_ncm/wNdpInDivisor
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		Divisor used for IN NTB Datagram payload alignment
+
+What:		/sys/class/net/<iface>/cdc_ncm/wNdpInPayloadRemainder
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		Remainder used to align input datagram payload within
+		the NTB: (Payload Offset) mod (wNdpInDivisor) =3D
+		wNdpInPayloadRemainder
+
+What:		/sys/class/net/<iface>/cdc_ncm/wNdpInAlignment
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		NDP alignment modulus for NTBs on the IN pipe. Shall
+		be a power of 2, and shall be at least 4.
+
+What:		/sys/class/net/<iface>/cdc_ncm/dwNtbOutMaxSize
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		OUT NTB Maximum Size
+
+What:		/sys/class/net/<iface>/cdc_ncm/wNdpOutDivisor
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		OUT NTB Datagram alignment modulus
+
+What:		/sys/class/net/<iface>/cdc_ncm/wNdpOutPayloadRemainder
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		Remainder used to align output datagram payload
+		offsets within the NTB: Padding, shall be transmitted
+		as zero by function, and ignored by host.  (Payload
+		Offset) mod (wNdpOutDivisor) =3D wNdpOutPayloadRemainder
+
+What:		/sys/class/net/<iface>/cdc_ncm/wNdpOutAlignment
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		NDP alignment modulus for use in NTBs on the OUT
+		pipe. Shall be a power of 2, and shall be at least 4.
+
+What:		/sys/class/net/<iface>/cdc_ncm/wNtbOutMaxDatagrams
+Date:		May 2014
+KernelVersion:	3.16
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		Maximum number of datagrams that the host may pack
+		into a single OUT NTB. Zero means that the device
+		imposes no limit.
--=20
2.0.0.rc4
