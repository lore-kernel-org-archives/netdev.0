From: Cong Wang <amwang@redhat.com>
Subject: Re: A soft lockup in vxlan module
Date: Wed, 07 Aug 2013 14:47:10 +0800
Message-ID: <1375858030.11370.25.camel@cr0>
References: <1375838634.11370.13.camel@cr0>
	 <20130806211347.44c14755@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61251 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755214Ab3HGGrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 02:47:17 -0400
In-Reply-To: <20130806211347.44c14755@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 21:13 -0700, Stephen Hemminger wrote:
> 
> Probably the flush_workqueue can just be removed and let the normal
> refcounting work. The workqueue has a reference to device and socket,
> therefore the cleanups should work correctly.

Sounds reasonable, I am testing the following patch:

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8bf31d9..c51ef9b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1837,8 +1837,6 @@ static void vxlan_dellink(struct net_device *dev,
struct list_head *head)
        struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
        struct vxlan_dev *vxlan = netdev_priv(dev);
 
-       flush_workqueue(vxlan_wq);
-
        spin_lock(&vn->sock_lock);
        hlist_del_rcu(&vxlan->hlist);
        spin_unlock(&vn->sock_lock);
