From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] netlink: silence compiler warning
Date: Fri, 04 Sep 2009 21:36:06 -0400
Message-ID: <4AA1C086.5000607@hp.com>
References: <4AA1B712.6060900@hp.com> <1252112881.27694.3.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:21897 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933982AbZIEBgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 21:36:15 -0400
In-Reply-To: <1252112881.27694.3.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcel,

Marcel Holtmann wrote:
> can we please add the err = -E... where it actually is needed and not
> stupidly go ahead and silence compiler warnings with err = 0. This has
> been posted before.

Sorry, I don't remember it being posted before.  If you look at the code
though, err is correctly initialized, gcc just can't figure it out.  The
choices I see are either what I originally posted, using uninitialized_var(err),
or the patch below.  It doesn't matter to me.

-Brian


diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 66f6ba0..8741036 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -177,6 +177,7 @@ int genl_register_mc_group(struct genl_family *family,
 		struct net *net;
 
 		rcu_read_lock();
+		err = 0;
 		for_each_net_rcu(net) {
 			err = netlink_change_ngroups(net->genl_sock,
 					mc_groups_longs * BITS_PER_LONG);
