From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] net: Prefer non link-local source addresses
Date: Thu, 1 Sep 2011 23:56:27 +0200
Message-ID: <20110901215627.GG1142123@jupiter.n2.diac24.net>
References: <1314908454-14359-1-git-send-email-jeff_harris@kentrox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Harris <jeff_harris@kentrox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:42519 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757961Ab1IAV4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Sep 2011 17:56:44 -0400
Content-Disposition: inline
In-Reply-To: <1314908454-14359-1-git-send-email-jeff_harris@kentrox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2011 at 04:20:54PM -0400, Jeff Harris wrote:
> Section 2.6.1 of RFC 3927 specifies that if link-local and routable addresses
> are available on an interface, a routable address is preferred.  Update the
> IPv4 source address selection algorithm to use a 169.254.x.x address only if
> another matching address is not found.

> +			if (ipv4_is_linklocal_169(ifa->ifa_address)) {
> +				lladdr = ifa->ifa_local;
> +				continue;
> +			}

IP addresses have a scope field:
# ip -4 a l eth0                                   
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    inet 10.0.0.1/24 brd 10.0.0.255 scope link eth0
    inet 172.22.80.50/25 brd 172.22.80.127 scope global eth0

would it not make sense to use to use that field instead?


-David
