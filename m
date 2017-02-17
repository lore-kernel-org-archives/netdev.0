From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] packet: Do not call fanout_release from atomic
 contexts
Date: Fri, 17 Feb 2017 11:13:33 -0500 (EST)
Message-ID: <20170217.111333.106912523796144773.davem@davemloft.net>
References: <1487190339-6366-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: anoob.soman@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44786 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934283AbdBQQNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 11:13:36 -0500
In-Reply-To: <1487190339-6366-1-git-send-email-anoob.soman@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anoob Soman <anoob.soman@citrix.com>
Date: Wed, 15 Feb 2017 20:25:39 +0000

> Commit 6664498280cf ("packet: call fanout_release, while UNREGISTERING a
> netdev"), unfortunately, introduced the following issues.
 ...
> To fix the above problems, remove the call to fanout_release() under
> rcu_read_lock(). Instead, call __dev_remove_pack(&fanout->prot_hook) and
> netdev_run_todo will be happy that &dev->ptype_specific list is empty. In order
> to achieve this, I moved dev_{add,remove}_pack() out of fanout_{add,release} to
> __fanout_{link,unlink}. So, call to {,__}unregister_prot_hook() will make sure
> fanout->prot_hook is removed as well.
> 
> Fixes: 6664498280cf ("packet: call fanout_release, while UNREGISTERING a netdev")
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Anoob Soman <anoob.soman@citrix.com>
> ---
>  Changes in v3:
>  - Removed extra variable from fanout_release(), per Eric's suggestion.
>  Changes in v2:
>  - Incorporated Eric's suggestion to do fanout_release_data() and kfree() after
>    synchronize_net()

Applied and queued up for -stable, thanks.
