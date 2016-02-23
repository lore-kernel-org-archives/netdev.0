From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH net-next RFC] rtnetlink: add new RTM_GETSTATS to dump
 link stats
Date: Tue, 23 Feb 2016 09:26:18 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F92CB7E894@HASMSX110.ger.corp.intel.com>
References: <1456207293-36903-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jhs@mojatatu.com" <jhs@mojatatu.com>,
	"Rosen, Rami" <rami.rosen@intel.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:1094 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110AbcBWJ0W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 04:26:22 -0500
In-Reply-To: <1456207293-36903-1-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

+	if (!dev)
+		return -ENODEV;
+
+	nskb = nlmsg_new(if_nlmsg_stats_size(dev), GFP_KERNEL);
+	if (!nskb)
+		return -ENOBUFS;
+
+	err = rtnl_fill_statsinfo(nskb, dev, RTM_NEWSTATS,
+				  NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0, 0);
+	if (err < 0) {

It should be here:  -EMSGSIZE implies BUG in if_nlmsg_stats_size  (instead of if_nlmsg_size)

+		/* -EMSGSIZE implies BUG in if_nlmsg_size */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(nskb);
+	} else {
+		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).portid);
+	}


Other than that, it seems ok, thanks for this patch!

Regards,
Rami Rosen
Intel Corporation
