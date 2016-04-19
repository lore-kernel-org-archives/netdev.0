From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 19:22:19 -0700
Message-ID: <1461032539.10638.143.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
	 <1461015356.10638.124.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160418.205755.87909888849343438.davem@davemloft.net>
	 <20160418.214851.122286645854721047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35942 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbcDSCWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 22:22:21 -0400
Received: by mail-pa0-f46.google.com with SMTP id er2so1271917pad.3
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 19:22:21 -0700 (PDT)
In-Reply-To: <20160418.214851.122286645854721047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 21:48 -0400, David Miller wrote:

> 
> And anyways, I get unaligned accesses without Roopa's changes :-/
> 
> davem@patience:~$ ip l l
> [3391066.656729] Kernel unaligned access at TPC[7d6c14] loopback_get_stats64+0x74/0xa0
> [3391066.672020] Kernel unaligned access at TPC[7d6c18] loopback_get_stats64+0x78/0xa0
> [3391066.687282] Kernel unaligned access at TPC[7d6c1c] loopback_get_stats64+0x7c/0xa0
> [3391066.702573] Kernel unaligned access at TPC[7d6c20] loopback_get_stats64+0x80/0xa0
> [3391066.717858] Kernel unaligned access at TPC[8609dc] dev_get_stats+0x3c/0xe0

Yes, rtnl_fill_stats() probably has the same mistake.

commit 550bce59baf3f3059cd4ae1e268f08f2d2cb1d5c
Author: Roopa Prabhu <roopa@cumulusnetworks.com>
Date:   Fri Apr 15 20:36:25 2016 -0700

    rtnetlink: rtnl_fill_stats: avoid an unnecssary stats copy
    
    This patch passes netlink attr data ptr directly to dev_get_stats
    thus elimiating a stats copy.
    
    Suggested-by: David Miller <davem@davemloft.net>
    Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
