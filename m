From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: fdb dump: optimize by saving last
 interface markers
Date: Thu, 01 Sep 2016 16:56:41 -0700 (PDT)
Message-ID: <20160901.165641.1996592771782783172.davem@davemloft.net>
References: <1472619405-50802-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, wkok@cumulusnetworks.com,
        stephen@networkplumber.org, jhs@mojatatu.com,
        makita.toshiaki@lab.ntt.co.jp, jiri@resnulli.us,
        idosch@mellanox.com, netdev@vger.kernel.org, minoura@valinux.co.jp,
        Dept-GELinuxNICDev@qlogic.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbcIAX4n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 19:56:43 -0400
In-Reply-To: <1472619405-50802-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue, 30 Aug 2016 21:56:45 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> fdb dumps spanning multiple skb's currently restart from the first
> interface again for every skb. This results in unnecessary
> iterations on the already visited interfaces and their fdb
> entries. In large scale setups, we have seen this to slow
> down fdb dumps considerably. On a system with 30k macs we
> see fdb dumps spanning across more than 300 skbs.
> 
> To fix the problem, this patch replaces the existing single fdb
> marker with three markers: netdev hash entries, netdevs and fdb
> index to continue where we left off instead of restarting from the
> first netdev. This is consistent with link dumps.
> 
> In the process of fixing the performance issue, this patch also
> re-implements fix done by
> commit 472681d57a5d ("net: ndo_fdb_dump should report -EMSGSIZE to rtnl_fdb_dump")
> (with an internal fix from Wilson Kok) in the following ways:
> - change ndo_fdb_dump handlers to return error code instead
> of the last fdb index
> - use cb->args strictly for dump frag markers and not error codes.
> This is consistent with other dump functions.
 ...
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>

Looks great, applied, thanks!
