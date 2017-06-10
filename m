From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: fix recursive locking warning in
 sctp_do_peeloff
Date: Sat, 10 Jun 2017 16:22:55 -0400 (EDT)
Message-ID: <20170610.162255.1370591270114423894.davem@davemloft.net>
References: <a5f7dc6e508e016041f685179f1d99fc04541bdd.1497077816.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        xiyou.wangcong@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33900 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbdFJUW5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:22:57 -0400
In-Reply-To: <a5f7dc6e508e016041f685179f1d99fc04541bdd.1497077816.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 10 Jun 2017 14:56:56 +0800

> Dmitry got the following recursive locking report while running syzkaller
> fuzzer, the Call Trace:
 ...
> This warning is caused by the lock held by sctp_getsockopt() is on one
> socket, while the other lock that sctp_close() is getting later is on
> the newly created (which failed) socket during peeloff operation.
> 
> This patch is to avoid this warning by use lock_sock with subclass
> SINGLE_DEPTH_NESTING as Wang Cong and Marcelo's suggestion.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Suggested-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
