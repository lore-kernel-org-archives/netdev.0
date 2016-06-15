From: Jesse Gross <jesse@kernel.org>
Subject: Re: [net-next PATCH v2 02/17] net: Combine GENEVE and VXLAN port
 notifiers into single functions
Date: Wed, 15 Jun 2016 16:50:46 -0700
Message-ID: <CAEh+42i8y70XsuuXs1+LYVxRomvJZUEWg6KhonoxvNqaYe9dtQ@mail.gmail.com>
References: <20160615220449.15575.17031.stgit@localhost.localdomain> <20160615220728.15575.62132.stgit@localhost.localdomain>
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
Received: from mail.kernel.org ([198.145.29.136]:48136 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932570AbcFOXvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 19:51:05 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 37052202BE
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 23:51:04 +0000 (UTC)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D26F0202EC
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 23:51:01 +0000 (UTC)
Received: by mail-qk0-f169.google.com with SMTP id p10so39029400qke.3
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 16:51:01 -0700 (PDT)
In-Reply-To: <20160615220728.15575.62132.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 3:07 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index e5e33cd01082..d12ee3a92fb5 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
>  static void geneve_notify_del_rx_port(struct geneve_sock *gs)
>  {
> -       struct net_device *dev;
> -       struct sock *sk = gs->sock->sk;
> -       struct net *net = sock_net(sk);
> -       sa_family_t sa_family = geneve_get_sk_family(gs);
> -       __be16 port = inet_sk(sk)->inet_sport;
> -
> -       rcu_read_lock();
> -       for_each_netdev_rcu(net, dev) {
> -               if (dev->netdev_ops->ndo_del_geneve_port)
> -                       dev->netdev_ops->ndo_del_geneve_port(dev, sa_family,
> -                                                            port);
> -       }
> -
> -       rcu_read_unlock();
> +       udp_tunnel_notify_add_rx_port(gs->sock, UDP_TUNNEL_TYPE_GENEVE);
>  }

Looks like a typo here - calling add instead of delete.
