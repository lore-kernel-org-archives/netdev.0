From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: call rcu_read_lock before checking for
 duplicate transport nodes
Date: Wed, 01 Mar 2017 12:51:44 -0500 (EST)
Message-ID: <20170301.125144.868804645631520813.davem@davemloft.net>
References: <d239fb1c1f86e3421de4a891f8a704d37b236cbf.1488256889.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com, andreyknvl@google.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdCARvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 12:51:51 -0500
In-Reply-To: <d239fb1c1f86e3421de4a891f8a704d37b236cbf.1488256889.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 28 Feb 2017 12:41:29 +0800

> Commit cd2b70875058 ("sctp: check duplicate node before inserting a
> new transport") called rhltable_lookup() to check for the duplicate
> transport node in transport rhashtable.
> 
> But rhltable_lookup() doesn't call rcu_read_lock inside, it could cause
> a use-after-free issue if it tries to dereference the node that another
> cpu has freed it. Note that sock lock can not avoid this as it is per
> sock.
> 
> This patch is to fix it by calling rcu_read_lock before checking for
> duplicate transport nodes.
> 
> Fixes: cd2b70875058 ("sctp: check duplicate node before inserting a new transport")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
