From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v3 3/3] bonding: add net_ratelimt to avoid spam
 in arp interval
Date: Tue, 25 Mar 2014 08:29:35 +0100
Message-ID: <20140325072935.GA1476@redhat.com>
References: <1395717697-11876-1-git-send-email-dingtianhong@huawei.com>
 <1395717697-11876-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: fubar@us.ibm.com, andy@greyhouse.net, joe@perches.com,
	kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43320 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753751AbaCYUED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 16:04:03 -0400
Content-Disposition: inline
In-Reply-To: <1395717697-11876-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2014 at 11:21:37AM +0800, Ding Tianhong wrote:
...snip...
>-	pr_debug("arp %d on slave %s: dst %pI4 src %pI4\n",
>-		 arp_op, slave_dev->name, &dest_ip, &src_ip);
>+	net_dbg_ratelimited("arp %d on slave %s: dst %pI4 src %pI4\n",
>+			    arp_op, slave_dev->name, &dest_ip, &src_ip);

I don't think we should ratelimit debug statements - as they're turned on
only when the user is actually debugging, so that all the debug statements
should be shown.

As an example here - I actually used it and grepped for a specific arp. If
it was ratelimited - I might have skipped it.

> 	if (outer->vlan_id) {
> 		if (inner->vlan_id) {
>-			pr_debug("inner tag: proto %X vid %X\n",
>-				 ntohs(inner->vlan_proto), inner->vlan_id);
>+			net_dbg_ratelimited("inner tag: proto %X vid %X\n",
>+					    ntohs(inner->vlan_proto),
>+					    inner->vlan_id);

Same here.

>-		pr_debug("outer reg: proto %X vid %X\n",
>-			 ntohs(outer->vlan_proto), outer->vlan_id);
>+		net_dbg_ratelimited("outer reg: proto %X vid %X\n",
>+				     ntohs(outer->vlan_proto), outer->vlan_id);

And here.

>-			if (bond->params.arp_validate && net_ratelimit())
>-				pr_warn("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
>-					bond->dev->name, &targets[i]);
>+			if (bond->params.arp_validate)
>+				net_dbg_ratelimited("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
>+						    bond->dev->name,
>+						    &targets[i]);

You've changed an already ratelimited warning with a debug statement. This
warning is here for a reason.

>-		pr_debug("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
>-			 bond->dev->name, &targets[i],
>-			 rt->dst.dev ? rt->dst.dev->name : "NULL");
>+		net_dbg_ratelimited("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
>+				    bond->dev->name, &targets[i],
>+				    rt->dst.dev ? rt->dst.dev->name : "NULL");

Again the dbg ratelimit.
