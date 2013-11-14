From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net v2 1/2] macvlan: introduce macvlan_dev_real_dev()
 helper function
Date: Thu, 14 Nov 2013 16:57:57 +0100
Message-ID: <20131114155756.GA4161@lion.mk-sys.cz>
References: <cover.1384436410.git.mkubecek@suse.cz>
 <b4ca4f2204f0ffb0bd7f959192462944a8d846a4.1384436410.git.mkubecek@suse.cz>
 <5284E637.5060805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lion.mk-sys.cz ([213.168.178.121]:40471 "EHLO lion.mk-sys.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753503Ab3KNQGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 11:06:36 -0500
Content-Disposition: inline
In-Reply-To: <5284E637.5060805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 10:03:19AM -0500, Vlad Yasevich wrote:
> On 11/14/2013 09:00 AM, Michal Kubecek wrote:
> >+#if IS_ENABLED(CONFIG_MACVLAN)
> >+static inline struct net_device *
> >+macvlan_dev_real_dev(const struct net_device *dev)
> >+{
> >+	struct macvlan_dev *macvlan = netdev_priv(dev);
> >+
> >+	return macvlan->lowerdev;
> >+}
> >+#else
> >+static inline struct net_device *
> >+macvlan_dev_real_dev(const struct net_device *dev)
> >+{
> >+	return NULL;
> >+}
> >+#endif
> >+
> 
> You may want to do the same here as was done for
> vlan_dev_real_dev(). This function is not intended to be called
> blindly and should always
> be called after netif_is_macvlan().

I'm not sure. It makes sense from the developer point of view: if we
find an inconsistency which must be caused by a bug in kernel code, do
panic so that the bug is found and fixed as soon as possible. However,
I remember a discussion where the point was that BUG() and BUG_ON()
should only be used if there is no way to recover. From this point of
view, WARN or WARN_ONCE might be better choice - but I'm not strictly
opposed to BUG().

                                                       Michal Kubecek
