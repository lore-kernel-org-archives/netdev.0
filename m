From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [patch net] net: sched: fix memleak for chain zero
Date: Wed, 6 Sep 2017 18:38:10 +0100
Message-ID: <20170906183810.7096036b@cakuba.netronome.com>
References: <20170906111419.5115-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:23077 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752335AbdIFRiO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 13:38:14 -0400
In-Reply-To: <20170906111419.5115-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  6 Sep 2017 13:14:19 +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> There's a memleak happening for chain 0. The thing is, chain 0 needs to
> be always present, not created on demand. Therefore tcf_block_get upon
> creation of block calls the tcf_chain_create function directly. The
> chain is created with refcnt == 1, which is not correct in this case and
> causes the memleak. So move the refcnt increment into tcf_chain_get
> function even for the case when chain needs to be created.
> 
> Reported-by: Jakub Kicinski <kubakici@wp.pl>
> Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Tested-by: Jakub Kicinski <jakub.kicinski@netronome.com>
