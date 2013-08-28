From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v10 09/11] vxlan: add ipv6 proxy support
Date: Wed, 28 Aug 2013 09:13:29 -0700
Message-ID: <20130828091329.32065ec2@nehalam.linuxnetplumber.net>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
	<1377667379-2315-10-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:46744 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150Ab3H1QNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 12:13:32 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so6480198pdj.4
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 09:13:32 -0700 (PDT)
In-Reply-To: <1377667379-2315-10-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Aug 2013 13:22:57 +0800
Cong Wang <amwang@redhat.com> wrote:

> +#if IS_ENABLED(CONFIG_IPV6)
> +static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
> +{
> +	struct vxlan_dev *vxlan = netdev_priv(dev);
> +	struct neighbour *n;
> +	union vxlan_addr ipa;
> +	const struct ipv6hdr *iphdr;
> +	const struct in6_addr *saddr, *daddr;
> +	struct nd_msg *msg;
> +	struct inet6_dev *in6_dev = NULL;
> +
> +	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());

You may have needed warn during debugging, but you should be able
to audit all the codepaths (this is a static function) to be sure
that this code is correct (ie rcu lock always held).
