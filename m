From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/3] bnxt_en: Fix RTNL lock usage in bnxt_sp_task().
Date: Wed, 25 Jan 2017 02:55:06 -0500
Message-ID: <1485330909-12037-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34340 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdAYHzU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 02:55:20 -0500
Received: by mail-pf0-f171.google.com with SMTP id e4so56459175pfg.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 23:55:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 2 function calls from bnxt_sp_task() that have buggy RTNL
usage.  These 2 functions take RTNL lock under some conditions, but
some callers (such as open, ethtool) have already taken RTNL.  These
3 patches fix the issue by making it clear that callers must take
RTNL.  If the caller is bnxt_sp_task() which does not automatically
take RTNL, we add a common scheme for bnxt_sp_task() to call these
functions properly under RTNL.


Michael Chan (3):
  bnxt_en: Fix bnxt_reset() in the slow path task.
  bnxt_en: Fix RTNL lock usage on bnxt_update_link().
  bnxt_en: Fix RTNL lock usage on bnxt_get_port_module_status().

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 78 ++++++++++++++++++-------------
 1 file changed, 46 insertions(+), 32 deletions(-)

-- 
1.8.3.1
