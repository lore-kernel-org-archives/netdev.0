From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next] net: vxlan: when lower dev unregisters
 remove vxlan dev as well
Date: Fri, 10 Jan 2014 13:01:18 -0800
Message-ID: <20140110130118.1893fcc3@nehalam.linuxnetplumber.net>
References: <1389386780-24827-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:37670 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbaAJVBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 16:01:21 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so5028084pdj.36
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 13:01:21 -0800 (PST)
In-Reply-To: <1389386780-24827-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jan 2014 21:46:20 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> +static int vxlan_lowerdev_event(struct notifier_block *unused,
> +				unsigned long event, void *ptr)
> +{
> +	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
> +	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
> +
> +	switch (event) {
> +	case NETDEV_UNREGISTER:
> +		/* Twiddle thumbs on netns device moves. */
> +		if (dev->reg_state != NETREG_UNREGISTERING)
> +			break;

No. Don't look at reg_state here. If moved from namespace
then it is a good as gone.
