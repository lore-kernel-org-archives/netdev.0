From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/3] bonding: ratelimit pr_err() for bond xmit
 broadcast
Date: Tue, 25 Mar 2014 00:19:23 -0700
Message-ID: <1395731963.3010.3.camel@joe-AO722>
References: <1395731037-4812-1-git-send-email-dingtianhong@huawei.com>
	 <1395731037-4812-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0043.hostedemail.com ([216.40.44.43]:41940 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751761AbaCYHT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 03:19:28 -0400
In-Reply-To: <1395731037-4812-3-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-25 at 15:03 +0800, Ding Tianhong wrote:
> It may spam if the system is out of the memory, add ratelimit for it.

Sorry, I didn't follow whatever discussion occurred here.

I thought you were going to use net_err_ratelimited
for these?

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
[]
> @@ -3656,8 +3656,8 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
> -				pr_err("%s: Error: bond_xmit_broadcast(): skb_clone() failed\n",
> -				       bond_dev->name);
> +				pr_err_ratelimited("%s: Error: bond_xmit_broadcast(): skb_clone() failed\n",
> +						   bond_dev->name);

also btw, it's better I think to use
%s, __func__ instead of embedding
explicit function names
