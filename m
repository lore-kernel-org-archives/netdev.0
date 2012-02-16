From: "Barak Witkowski" <barak@broadcom.com>
Subject: [PATCH linux-firmware 0/1] bnx2x: adding fw 7.2.16
Date: Thu, 16 Feb 2012 15:07:57 +0200
Message-ID: <1329397677.13643.13.camel@lb-tlvb-barak.il.broadcom.com>
Reply-To: barak@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Woodhouse" <dwmw2@infradead.org>,
	"Ben Hutchings" <ben@decadent.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2176 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944Ab2BPNLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 08:11:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series is actually only a single patch, but since it is too
big for the mailing list, you can also find it at the following link:
http://linux.broadcom.com/eilong/FW-7.2.16.0/

This new FW adds the ability to aggregate packets for GRO (and not just
LRO) and also fixes some bugs. Please consider adding it to the FW tree:

1. Added new aggregation mode: GRO. In this mode packets are aggregated such
   that the original packets can be reconstructed by the O/S.
2. 57712 HW bug workaround - initialized all CAM TM registers to 0x32.
3. Adding the FCoE statistics structures to the BNX2X HSI.
4. Wrong configuration of TX HW input buffer size may cause theoretical
   performance effect. Performed configuration fix.
5. FCOE - Arrival of packets beyond task IO size can lead to crash.
   Fix firmware data-in flow.
6. iSCSI - In rare cases of on-chip termination the graceful termination timer
   hangs, and the termination doesn't complete. Firmware fix to MSL timer
   tolerance.
7. iSCSI - Chip hangs when target sends FIN out-of-order or with isles open at
   the initiator side. Firmware implementation corrected to drop FIN received
   out-of-order or with isles still open.
8. iSCSI - Chip hangs when in case of retransmission not aligned to 4-bytes from
   the beginning of iSCSI PDU. Firmware implementation corrected to support
   arbitrary aligned retransmissions.
9. iSCSI - Arrival of target-initiated NOP-IN during intense ISCSI traffic might
   lead to crash. Firmware fix to relevant flow.

Thanks,
Barak
