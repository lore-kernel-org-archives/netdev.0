From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Mon, 22 Oct 2012 22:45:02 +0200
Message-ID: <1350938702.8609.1299.camel@edumazet-glaptop>
References: <508123AC.5080208@parallels.com>  <50858ABD.2000206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:64693 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195Ab2JVUpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 16:45:07 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so962000eaa.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 13:45:05 -0700 (PDT)
In-Reply-To: <50858ABD.2000206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-22 at 14:04 -0400, Brian Haley wrote:

> +	char devname[IFNAMSIZ];
> +
> +	ret = 0;
> +	if (sk->sk_bound_dev_if == 0)
> +		goto out;
> +
> +	ret = -EINVAL;
> +	if (len < IFNAMSIZ)
> +		goto out;
> +	if (len > IFNAMSIZ)
> +		len = IFNAMSIZ;
> +
> +	rcu_read_lock();
> +	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
> +	if (dev)
> +		strcpy(dev->name, devname);
> +	rcu_read_unlock();
> +	ret = -ENODEV;

You probably meant

	strcpy(devname, dev->name)

By the way, this is not really safe in case device is renamed
