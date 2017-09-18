From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] tls: Add generic NIC offload infrastructure.
Date: Mon, 18 Sep 2017 16:52:21 +0200
Message-ID: <87poaocb4q.fsf@stressinduktion.org>
References: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
        <1505385988-94522-6-git-send-email-ilyal@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, davejwatson@fb.com,
        tom@herbertland.com, borisp@mellanox.com, aviadye@mellanox.com,
        liranl@mellanox.com
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55395 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752823AbdIROwZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 10:52:25 -0400
In-Reply-To: <1505385988-94522-6-git-send-email-ilyal@mellanox.com> (Ilya
        Lesokhin's message of "Thu, 14 Sep 2017 13:46:28 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilya Lesokhin <ilyal@mellanox.com> writes:

> +/* We assume that the socket is already connected */
> +static struct net_device *get_netdev_for_sock(struct sock *sk)
> +{
> +	struct inet_sock *inet = inet_sk(sk);
> +	struct net_device *netdev = NULL;
> +
> +	netdev = dev_get_by_index(sock_net(sk), inet->cork.fl.flowi_oif);
> +
> +	return netdev;
> +}

The user should be aware of that they can't migrate the socket to
another interface if they got hw offloaded. This is not the case for
software offload. Thus I think the user has to opt in and it shouldn't
be a heuristic until we can switch back to sw offload path.

Maybe change flowi_oif to sk_bound_dev_if and somwhow lock it against
further changes if hw tls is in use?

Thanks,
Hannes
