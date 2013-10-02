From: Oussama Ghorbel <ou.ghorbel@gmail.com>
Subject: The check of upper MTU limit when changing it in ip6 gre tunnel seems incorrect.
Date: Wed, 2 Oct 2013 17:44:29 +0100
Message-ID: <CABfLueFJWv0OvcDmP7TMTF4wHjjv5QW_Qt+ULSDBciX==HsXQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:47277 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109Ab3JBQoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 12:44:30 -0400
Received: by mail-ie0-f177.google.com with SMTP id qd12so2409772ieb.22
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 09:44:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check of upper MTU limit when changing it in ip6 gre tunnel seems incorrect.
The function in question is:

static int ip6gre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
{
    struct ip6_tnl *tunnel = netdev_priv(dev);

    if (new_mtu < 68 ||
        new_mtu > 0xFFF8 - dev->hard_header_len - tunnel->hlen)
        return -EINVAL;
    dev->mtu = new_mtu;
    return 0;
}

However the dev->hard_header_len and tunnel->hlen are initialized in
the following way in ip6gre_tnl_link_config():

int addend = sizeof(struct ipv6hdr) + 4;
...
dev->hard_header_len = rt->dst.dev->hard_header_len + addend;
...
t->hlen = addend; // t is ip6_tnl pointer

As you see the information t->hlen is already included in
dev->hard_header_len, so why calculate it twice?

Thanks
