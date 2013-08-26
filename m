From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/8] net: move netdev_upper to netdevice.h
Date: Mon, 26 Aug 2013 18:41:15 +0200
Message-ID: <20130826164115.GA1413@minipsycho.brq.redhat.com>
References: <1377534533-6944-1-git-send-email-vfalico@redhat.com>
 <1377534533-6944-2-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:40517 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086Ab3HZQlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 12:41:19 -0400
Received: by mail-ee0-f50.google.com with SMTP id d51so1731079eek.37
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 09:41:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1377534533-6944-2-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 26, 2013 at 06:28:46PM CEST, vfalico@redhat.com wrote:
>So that any device can work with it to see its upper/master devices. It is
>rcu'd and rtnl_lock protected, so one should either hold the rtnl_lock() or
>to use the _rcu() functions for it.
>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: Eric Dumazet <edumazet@google.com>
>CC: Jiri Pirko <jiri@resnulli.us>
>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>CC: Cong Wang <amwang@redhat.com>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> include/linux/netdevice.h |    8 ++++++++
> net/core/dev.c            |    8 --------
> 2 files changed, 8 insertions(+), 8 deletions(-)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 077363d..8cc7f43 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -2764,6 +2764,14 @@ extern int		netdev_tstamp_prequeue;
> extern int		weight_p;
> extern int		bpf_jit_enable;
> 
>+struct netdev_upper {
>+	struct net_device *dev;
>+	bool master;
>+	struct list_head list;
>+	struct rcu_head rcu;
>+	struct list_head search_list;
>+};
>+


I like your patchset.  However I'm not entirely comfortable with exposing
this struct. I would love to have it "under control" in net/core/dev.c

I'm thinking of some getter/iterator for this use. It can work by
type as well so you would be able to remove the checks from bonding
code.
