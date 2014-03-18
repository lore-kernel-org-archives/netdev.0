From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next v2 2/3] bonding: support QinQ for bond arp interval
Date: Tue, 18 Mar 2014 10:59:58 -0700
Message-ID: <7072.1395165598@death.nxdomain>
References: <1395139433-19576-1-git-send-email-dingtianhong@huawei.com> <1395139433-19576-3-git-send-email-dingtianhong@huawei.com> <20140318120558.GA6430@redhat.com>
Cc: Ding Tianhong <dingtianhong@huawei.com>, andy@greyhouse.net,
	kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:42236 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756647AbaCRSAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 14:00:05 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 18 Mar 2014 12:00:05 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 8F51719D8042
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 11:59:59 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2IHxKxQ7602666
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 18:59:20 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s2II3a2u016428
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 12:03:37 -0600
In-reply-to: <20140318120558.GA6430@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav Falico <vfalico@redhat.com> wrote:

>On Tue, Mar 18, 2014 at 06:43:52PM +0800, Ding Tianhong wrote:
>...snip...
>>-	if (vlan_id) {
>>-		skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
>>+	if (outer->vlan_id) {
>>+		if (inner->vlan_id) {
>>+			pr_debug("inner tag: proto %X vid %X\n",
>>+				 ntohs(inner->vlan_proto), inner->vlan_id);
>>+			skb = __vlan_put_tag(skb, inner->vlan_proto, inner->vlan_id);
>>+			if (!skb) {
>>+				pr_err("failed to insert inner VLAN tag\n");
>>+				return;
>>+			}
>>+		}
>>+
>>+		pr_debug("outer reg: proto %X vid %X\n",
>>+			 ntohs(outer->vlan_proto), outer->vlan_id);
>>+		skb = vlan_put_tag(skb, outer->vlan_proto, outer->vlan_id);
>
>If I read correctly then the inner->vlan_proto will always be ETH_P_8021AD,
>whilst the outer will also always be ETH_P_8021Q. So I think it'd be a lot
>easier (and more readable) to just pass 2 vlan ids, and set those protos
>statically - that will save you from adding that new function to vlan core,
>fro madding a new struct that you've added here and make it several lines
>less.

	Do you mean that the outer will always be 8021AD and the inner
8021Q?  The inner/outer terminology is making my brain hurt, since the
ip commands to configure them look backwards to me.  I think of it as
the outer tag is the first one sequentially in the ethernet header, and
the inner tag is second in the header.

	Anyway, in the past, I've seen configurations with 802.1q VLANs
nested such that the inner and outer tags were both 802.1q 0x8100
ethertype, so I'm not sure that hard-coding these is necessarily a good
idea.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
