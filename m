From: Arun Parameswaran <aparames@broadcom.com>
Subject: [PATCH 0/2] Fix couple of issues with 'ethtool' get/set API's
Date: Fri, 22 May 2015 15:43:27 -0700
Message-ID: <1432334609-3971-1-git-send-email-aparames@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jdzheng@broadcom.com>,
	<aparames@broadcom.com>
To: Ben Hutchings <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:10976 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422688AbbEVWnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 18:43:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
The patch fixes 2 issues with 'ethtool' getting/setting parametres in
the do_gset() do_sset() API's.

I have pushed a patch to the Kernel to fix an issue in the handling of
the 'ethtool' commands which got accepted.
This Kernel patch was based on Linux v4.1-rc4 and is available in:
https://github.com/Broadcom/cygnus-linux/tree/net-core-ethtool-fix-v1

The Kernel was always clearing the command from the 'ethtool' resulting
in all operations to deal with PHY0. This prevents querying/setting
PHY 1's settings.

The first patch is required due to the fact that Kernel will not be
clearing the command data structure. Without this the query will fail
as the command will get to the Kernel with arbitary phyad info.

The second patch is to fix the issue in which the 'ethtool' gets the
settings of the wrong phyad before applying the new settings.

These changes will still work with older Kernel's (as the Kernel
clears the command data structure).

Thanks

Arun Parameswaran (2):
  ethtool: Clear the command data structure before sending requests
  ethtool: Fix an issue with handling 'phyad' while updating settings

 ethtool.c |    9 +++++++++
 1 file changed, 9 insertions(+)

-- 
1.7.9.5
