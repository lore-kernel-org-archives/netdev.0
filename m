From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 2/3] bonding: support QinQ for bond arp
 interval
Date: Tue, 18 Mar 2014 13:05:58 +0100
Message-ID: <20140318120558.GA6430@redhat.com>
References: <1395139433-19576-1-git-send-email-dingtianhong@huawei.com>
 <1395139433-19576-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: fubar@us.ibm.com, andy@greyhouse.net, kaber@trash.net,
	davem@davemloft.net, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1747 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754145AbaCRMGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 08:06:24 -0400
Content-Disposition: inline
In-Reply-To: <1395139433-19576-3-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 06:43:52PM +0800, Ding Tianhong wrote:
...snip...
>-	if (vlan_id) {
>-		skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
>+	if (outer->vlan_id) {
>+		if (inner->vlan_id) {
>+			pr_debug("inner tag: proto %X vid %X\n",
>+				 ntohs(inner->vlan_proto), inner->vlan_id);
>+			skb = __vlan_put_tag(skb, inner->vlan_proto, inner->vlan_id);
>+			if (!skb) {
>+				pr_err("failed to insert inner VLAN tag\n");
>+				return;
>+			}
>+		}
>+
>+		pr_debug("outer reg: proto %X vid %X\n",
>+			 ntohs(outer->vlan_proto), outer->vlan_id);
>+		skb = vlan_put_tag(skb, outer->vlan_proto, outer->vlan_id);

If I read correctly then the inner->vlan_proto will always be ETH_P_8021AD,
whilst the outer will also always be ETH_P_8021Q. So I think it'd be a lot
easier (and more readable) to just pass 2 vlan ids, and set those protos
statically - that will save you from adding that new function to vlan core,
fro madding a new struct that you've added here and make it several lines
less.
