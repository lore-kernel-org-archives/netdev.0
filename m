From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: call inet_add_protocol after
 register_pernet_subsys in dccp_v4_init
Date: Tue, 20 Jun 2017 15:32:12 -0400 (EDT)
Message-ID: <20170620.153212.1980022885551368458.davem@davemloft.net>
References: <9306540d6ad77c20e75b506df5cbd833c749f523.1497944558.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751901AbdFTTcO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:32:14 -0400
In-Reply-To: <9306540d6ad77c20e75b506df5cbd833c749f523.1497944558.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 20 Jun 2017 15:42:38 +0800

> Now dccp_ipv4 works as a kernel module. During loading this module, if
> one dccp packet is being recieved after inet_add_protocol but before
> register_pernet_subsys in which v4_ctl_sk is initialized, a null pointer
> dereference may be triggered because of init_net.dccp.v4_ctl_sk is 0x0.
> 
> Jianlin found this issue when the following call trace occurred:
 ...
> This patch is to move inet_add_protocol after register_pernet_subsys in
> dccp_v4_init, so that v4_ctl_sk is initialized before any incoming dccp
> packets are processed.
> 
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
