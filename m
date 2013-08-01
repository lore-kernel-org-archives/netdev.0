From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 5/5] bonding: initial RCU conversion
Date: Thu, 1 Aug 2013 14:46:43 +0800
Message-ID: <51FA0453.5000902@huawei.com>
References: <1375283553-32070-1-git-send-email-nikolay@redhat.com> <1375283553-32070-6-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <andy@greyhouse.net>,
	<davem@davemloft.net>, <fubar@us.ibm.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64743 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab3HAGsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 02:48:22 -0400
In-Reply-To: <1375283553-32070-6-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/7/31 23:12, Nikolay Aleksandrov wrote:
> This patch does the initial bonding conversion to RCU. After it the
> following modes are protected by RCU alone: roundrobin, active-backup,
> broadcast and xor. Modes ALB/TLB and 3ad still acquire bond->lock for
> reading, and will be dealt with later. curr_active_slave needs to be
> dereferenced via rcu in the converted modes because the only thing
> protecting the slave after this patch is rcu_read_lock, so we need the
> proper barrier for weakly ordered archs and to make sure we don't have
> stale pointer. It's not tagged with __rcu yet because there's still work
> to be done to remove the curr_slave_lock, so sparse will complain when
> rcu_assign_pointer and rcu_dereference are used, but the alternative to use
> rcu_dereference_protected would've created much bigger code churn which is
> more difficult to test and review. That will be converted in time.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>


great job! but I think you miss come place to replace by rcu protect.
example: bonding_show_active_slave() still has curr = bond->curr_active_slave,
so I think you could replace them all and send together.
