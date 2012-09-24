From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 3/3] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 21:55:00 +0200
Message-ID: <1348516500.26828.1570.camel@edumazet-glaptop>
References: <20120924184304.727711327@vyatta.com>
	 <20120924185050.162920909@vyatta.com>
	 <1348515547.26828.1538.camel@edumazet-glaptop>
	 <20120924124657.4541c186@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44661 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017Ab2IXTzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 15:55:04 -0400
Received: by bkcjk13 with SMTP id jk13so1153973bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 12:55:03 -0700 (PDT)
In-Reply-To: <20120924124657.4541c186@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 12:46 -0700, Stephen Hemminger wrote:

> +	f = vxlan_find_mac(vxlan, src_mac);
> +	if (likely(f)) {
> +		f->used = jiffies;
> +		if (likely(f->remote_ip == src_ip))
> +			return;
> +
> +		f->remote_ip = src_ip;
> +		f->updated = jiffies;
> +
> +		if (net_ratelimit())
> +			netdev_info(dev,
> +				    "%pM migrated from %pI4 to %pI4\n",
> +				    src_mac, &f->remote_ip, &src_ip);


This message is useless, as previous f_remote_ip content was already
overwritten.
