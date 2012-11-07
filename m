From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 0/2] bnx2x: Enable cnic at run-time
Date: Wed, 7 Nov 2012 12:45:46 +0200
Message-ID: <1352285148-21784-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com,
	"Merav Sicron" <meravs@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3568 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285Ab2KGHg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2012 02:36:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series removes the BCM_CNIC bnx2x define, and eliminates the use of
the CONFIG_CNIC kconfig option.
The define removal is mainly important for SR-IOV, as the VF driver will use the
same code as the PF/hypervisor driver. Since storage is not supported in
SR-IOV (while is usually enabled in the non SR-IOV driver), we don't want to
waste resources on it.
After this change, cnic-related resources are allocated only when the cnic
module registers with bnx2x (which means that the user asked for storage
services). Also only at this stage the HW is configured to non-NIC (offload)
mode.
The first patch is the driver-FW HSI addition to change the 'update' ramrod for
offload mode configuration at run-time.
The second patch is for the removal of the BCM_CNIC define, and for separating
the load flow to two stages, one for L2 and one for cnic-related stuff.

Please consider applying this patch series to net-next.

Thanks,
Merav
