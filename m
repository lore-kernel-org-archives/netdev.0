From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Wed, 12 Apr 2017 14:30:37 -0700
Message-ID: <20170412143037.5fd7a088@xeon-e3>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36095 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752304AbdDLVak (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 17:30:40 -0400
Received: by mail-pg0-f41.google.com with SMTP id g2so20407870pge.3
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 14:30:40 -0700 (PDT)
In-Reply-To: <20170412.145415.1441440342830198148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Apr 2017 14:54:15 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index b0aa089..071a58b 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1891,9 +1891,17 @@ struct net_device {
>  	struct lock_class_key	*qdisc_tx_busylock;
>  	struct lock_class_key	*qdisc_running_key;
>  	bool			proto_down;
> +	struct bpf_prog __rcu	*xdp_prog;

It would be good if all devices could reuse this for the xdp_prog pointer.
It would allow for could be used for introspection utility functions in future.
