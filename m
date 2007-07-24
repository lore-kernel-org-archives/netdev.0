From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [GENETLINK]: Fix race in genl_unregister_mc_groups()
Date: Tue, 24 Jul 2007 23:51:13 +0200
Message-ID: <20070724215113.GF9285@postel.suug.ch>
References: <20070724094557.GE9285@postel.suug.ch> <46A62564.3070006@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, johannes@sipsolutions.net,
	netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:32805 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754281AbXGXVux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 17:50:53 -0400
Content-Disposition: inline
In-Reply-To: <46A62564.3070006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Brian Haley <brian.haley@hp.com> 2007-07-24 12:14
> Thomas Graf wrote:
> >@@ -217,14 +229,8 @@ EXPORT_SYMBOL(genl_register_mc_group);
> > void genl_unregister_mc_group(struct genl_family *family,
> > 			      struct genl_multicast_group *grp)
> > {
> >-	BUG_ON(grp->family != family);
> > 	genl_lock();
> >-	netlink_clear_multicast_users(genl_sock, grp->id);
> >-	clear_bit(grp->id, mc_groups);
> >-	list_del(&grp->list);
> >-	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
> >-	grp->id = 0;
> >-	grp->family = NULL;
> >+	genl_unregister_mc_group(family, grp);
> > 	genl_unlock();
> > }
> 
> Shouldn't this be __genl_unregister_mc_group(family, grp) ?

Yes, thank for you noticing.
