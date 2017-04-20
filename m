From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] net sched actions: allocate act cookie early
Date: Thu, 20 Apr 2017 16:32:43 -0400 (EDT)
Message-ID: <20170420.163243.2282962634528556782.davem@davemloft.net>
References: <20170420120826.7641-1-w.bumiller@proxmox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: w.bumiller@proxmox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943112AbdDTUcp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 16:32:45 -0400
In-Reply-To: <20170420120826.7641-1-w.bumiller@proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Date: Thu, 20 Apr 2017 14:08:26 +0200

> Policing filters do not use the TCA_ACT_* enum and the tb[]
> nlattr array in tcf_action_init_1() doesn't get filled for
> them so we should not try to look for a TCA_ACT_COOKIE
> attribute in the then uninitialized array.
> The error handling in cookie allocation then calls
> tcf_hash_release() leading to invalid memory access later
> on.
> Additionally, if cookie allocation fails after an already
> existing non-policing filter has successfully been changed,
> tcf_action_release() should not be called, also we would
> have to roll back the changes in the error handling, so
> instead we now allocate the cookie early and assign it on
> success at the end.
> 
> CVE-2017-7979
> Fixes: 1045ba77a596 ("net sched actions: Add support for user cookies")
> Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied and queued up for -stable.
