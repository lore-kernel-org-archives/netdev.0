From: Jesse Gross <jesse@kernel.org>
Subject: Re: [net-next PATCH v2 03/17] net: Merge VXLAN and GENEVE push
 notifiers into a single notifier
Date: Wed, 15 Jun 2016 16:51:04 -0700
Message-ID: <CAEh+42hRJwqgD1wBxVq-SaqmJ5drteUrB4YV5pUCCgKpyqiz2A@mail.gmail.com>
References: <20160615220449.15575.17031.stgit@localhost.localdomain> <20160615220735.15575.36973.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org,
	Hannes Frederic Sowa <hannes@redhat.com>,
	eugenia@mellanox.com, Jiri Benc <jbenc@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	saeedm@mellanox.com, Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>, michael.chan@broadcom.com,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:48346 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932570AbcFOXvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 19:51:22 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 4C1E5202FF
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 23:51:20 +0000 (UTC)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8F4E6202C8
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 23:51:19 +0000 (UTC)
Received: by mail-qk0-f169.google.com with SMTP id a186so39058864qkf.0
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 16:51:19 -0700 (PDT)
In-Reply-To: <20160615220735.15575.36973.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 3:07 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d101e4d904ba..7f45e96967ce 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1050,6 +1052,19 @@ struct tc_to_netdev {
>   *     address family that vxlan is not listening to anymore. The operation
>   *     is protected by the vxlan_net->sock_lock.
>   *
> + * void (*ndo_udp_tunnel_add)(struct net_device *dev,
> + *                           struct udp_tunnel_info *ti);
> + *     Called by UDP tunnel to notify a driver about the UDP port and socket
> + *     address family that a UDP tunnel is listnening to. It is called only
> + *     when a new port starts listening. The operation is protected by the
> + *     tunnel socket lock.
> + *
> + * void (*ndo_udp_tunnel_del)(struct net_device *dev,
> + *                           struct udp_tunnel_info *ti);
> + *     Called by UDP tunnel to notify the driver about a UDP port and socket
> + *     address family that the UDP tunnel is not listening to anymore. The
> + *     operation is protected by the tunnel socket lock.

I think these comments are out of date - these operations are now
protected by RTNL instead of individual tunnel locks. Having
individual locks doesn't really work because drivers likely share
information for different tunnel types in the same data structures.
