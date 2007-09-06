From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] devinet: show all addresses assigned to interface
Date: Thu, 06 Sep 2007 20:15:40 +0200
Message-ID: <46E043CC.4090800@trash.net>
References: <20070906161000.74923fff@oldman>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000907030907050001000707"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38263 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755869AbXIFSSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 14:18:08 -0400
In-Reply-To: <20070906161000.74923fff@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000907030907050001000707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> Bug: http://bugzilla.kernel.org/show_bug.cgi?id=8876
>
> Not all ips are shown by "ip addr show" command when IPs number assigned to an
> interface is more than 60-80 (in fact it depends on broadcast/label etc
> presence on each address).
>
> Steps to reproduce:
> It's terribly simple to reproduce:
>
> # for i in $(seq 1 100); do ip ad add 10.0.$i.1/24 dev eth10 ; done
> # ip addr show
>
> this will _not_ show all IPs.
> Looks like the problem is in netlink/ipv4 message processing.
>
> This is fix from bug submitter, it looks correct.
>   

The same bug was introduced in decnet. Both are 2.6.22 regressions.

Signed-off-by: Patrick McHardy <kaber@trash.net>


--------------000907030907050001000707
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index fa6604f..8def682 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -814,7 +814,7 @@ static int dn_nl_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 		for (ifa = dn_db->ifa_list, dn_idx = 0; ifa;
 		     ifa = ifa->ifa_next, dn_idx++) {
 			if (dn_idx < skip_naddr)
-				goto cont;
+				continue;
 
 			if (dn_nl_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
 					      cb->nlh->nlmsg_seq, RTM_NEWADDR,

--------------000907030907050001000707--
