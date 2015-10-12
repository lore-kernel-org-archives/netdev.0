From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next 1/4] bridge: vlan: use proper rcu for the vlgrp
 member
Date: Mon, 12 Oct 2015 20:29:55 +0300
Message-ID: <20151012172921.GB6756@colbert.mtl.com>
References: <1444650069-32572-1-git-send-email-razor@blackwall.org>
 <1444650069-32572-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <shm@cumulusnetworks.com>,
	<roopa@cumulusnetworks.com>, <stephen@networkplumber.org>,
	<bridge@lists.linux-foundation.org>, <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0065.outbound.protection.outlook.com ([157.56.112.65]:60288
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751633AbbJLRaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2015 13:30:04 -0400
Content-Disposition: inline
In-Reply-To: <1444650069-32572-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 12, 2015 at 02:41:06PM IDT, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
Hi Nik,

Small nitpick:

<snip>

>@@ -825,17 +848,19 @@ unlock:
> 
> int br_vlan_init(struct net_bridge *br)
> {
>+	struct net_bridge_vlan_group *vg;
> 	int ret = -ENOMEM;
> 
>-	br->vlgrp = kzalloc(sizeof(struct net_bridge_vlan_group), GFP_KERNEL);
>-	if (!br->vlgrp)
>+	vg = kzalloc(sizeof(struct net_bridge_vlan_group), GFP_KERNEL);
Maybe just do sizeof(*vg)?
>+	if (!vg)
> 		goto out;
>-	ret = rhashtable_init(&br->vlgrp->vlan_hash, &br_vlan_rht_params);
>+	ret = rhashtable_init(&vg->vlan_hash, &br_vlan_rht_params);
> 	if (ret)
> 		goto err_rhtbl;
>-	INIT_LIST_HEAD(&br->vlgrp->vlan_list);
>+	INIT_LIST_HEAD(&vg->vlan_list);
> 	br->vlan_proto = htons(ETH_P_8021Q);
> 	br->default_pvid = 1;
>+	rcu_assign_pointer(br->vlgrp, vg);
> 	ret = br_vlan_add(br, 1,
> 			  BRIDGE_VLAN_INFO_PVID | BRIDGE_VLAN_INFO_UNTAGGED |
> 			  BRIDGE_VLAN_INFO_BRENTRY);
>@@ -846,9 +871,9 @@ out:
> 	return ret;

</snip>

>-- 
>2.4.3
>
