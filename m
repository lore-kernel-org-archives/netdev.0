From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH 0/2] i40e: fix firmware update
Date: Fri,  1 Sep 2017 16:02:32 +0200
Message-ID: <20170901140234.7840-1-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34577 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751966AbdIAOCp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 10:02:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch fixes the firmware update which is currently broken and
results in a bad flash (corrupt firmware). Recovery is possible with a
fixed driver.
The second patch reverts a commit that causes the firmware checksum
verification to fail right after a successful flash. This is related to
a recent workqueue change. Haven't gotten to the bottom of this yet, but
for the sake of a smooth firmware update experience let's revert the
commit for now.

Stefan Assmann (2):
  i40e: use non-locking i40e_read_nvm_word() function during nvmupdate
  Revert "i40e: remove WQ_UNBOUND and the task limit of our workqueue"

 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 +++++-------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c  | 24 ++++++++++++++++++++++--
 2 files changed, 27 insertions(+), 9 deletions(-)

-- 
2.13.5
