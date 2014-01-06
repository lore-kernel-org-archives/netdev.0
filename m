From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] bridge: spin_lock fix plus sysfs cleanup
Date: Mon, 06 Jan 2014 11:00:25 -0800
Message-ID: <20140106185718.10912.92289.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, curt@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:57008 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755257AbaAFTAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 14:00:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements:

- br_multicast_set_hash_max() is called from process context (via sysfs)
  and needs spin_lock_bh to disable bhs.

- cleanup bridge sysfs definitions by using DEVICE_ATTR_xx macros

---

Curt Brune (1):
      bridge: use spin_lock_bh() in br_multicast_set_hash_max

Scott Feldman (1):
      bridge: use DEVICE_ATTR_xx macros


 net/bridge/br_multicast.c |    4 -
 net/bridge/br_sysfs_br.c  |  249 ++++++++++++++++++++-------------------------
 2 files changed, 110 insertions(+), 143 deletions(-)

-- 
Signature
