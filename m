From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: Fix a scheduling-while-atomic bug in del_chan
Date: Mon, 31 Jul 2017 21:59:48 -0700 (PDT)
Message-ID: <20170731.215948.1332618179008379005.davem@davemloft.net>
References: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbdHAE7t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 00:59:49 -0400
In-Reply-To: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Mon, 31 Jul 2017 18:07:38 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The PPTP set the pptp_sock_destruct as the sock's sk_destruct, it would
> trigger this bug when __sk_free is invoked in atomic context, because of
> the call path pptp_sock_destruct->del_chan->synchronize_rcu.
> 
> Now move the synchronize_rcu to pptp_release from del_chan. This is the
> only one case which would free the sock and need the synchronize_rcu.
> 
> The following is the panic I met with kernel 3.3.8, but this issue should
> exist in current kernel too according to the codes.
 ...
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Applied, thanks.
