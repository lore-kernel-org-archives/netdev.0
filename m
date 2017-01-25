From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bnxt_en: Fix RTNL lock usage in bnxt_sp_task().
Date: Wed, 25 Jan 2017 13:27:52 -0500 (EST)
Message-ID: <20170125.132752.1057010400377426314.davem@davemloft.net>
References: <1485330909-12037-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57694 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751906AbdAYS1x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 13:27:53 -0500
In-Reply-To: <1485330909-12037-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Wed, 25 Jan 2017 02:55:06 -0500

> There are 2 function calls from bnxt_sp_task() that have buggy RTNL
> usage.  These 2 functions take RTNL lock under some conditions, but
> some callers (such as open, ethtool) have already taken RTNL.  These
> 3 patches fix the issue by making it clear that callers must take
> RTNL.  If the caller is bnxt_sp_task() which does not automatically
> take RTNL, we add a common scheme for bnxt_sp_task() to call these
> functions properly under RTNL.

Series applied, thanks Michael.

You can sprinkle some ASSERT_RTNL(); in the functions that require
RTNL to be held if you like.
