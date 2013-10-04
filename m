From: Oussama Ghorbel <ou.ghorbel@gmail.com>
Subject: Re: The check of upper MTU limit when changing it in ip6 gre tunnel
 seems incorrect.
Date: Fri, 4 Oct 2013 10:58:00 +0100
Message-ID: <CABfLueHGnjQZ7V+waNgxh0o=3nfcANvkKGragO2ZAGxDKNuyAg@mail.gmail.com>
References: <CABfLueFJWv0OvcDmP7TMTF4wHjjv5QW_Qt+ULSDBciX==HsXQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:51734 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438Ab3JDJ6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 05:58:00 -0400
Received: by mail-ie0-f173.google.com with SMTP id ar20so8615971iec.32
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 02:58:00 -0700 (PDT)
In-Reply-To: <CABfLueFJWv0OvcDmP7TMTF4wHjjv5QW_Qt+ULSDBciX==HsXQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have sent this patch to address the issue.

[PATCH] Fix the upper MTU limit in ipv6 GRE tunnel

On Wed, Oct 2, 2013 at 5:44 PM, Oussama Ghorbel <ou.ghorbel@gmail.com> wrote:
> The check of upper MTU limit when changing it in ip6 gre tunnel seems incorrect.
> The function in question is:
>
> static int ip6gre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
> {
>     struct ip6_tnl *tunnel = netdev_priv(dev);
>
>     if (new_mtu < 68 ||
>         new_mtu > 0xFFF8 - dev->hard_header_len - tunnel->hlen)
>         return -EINVAL;
>     dev->mtu = new_mtu;
>     return 0;
> }
>
> However the dev->hard_header_len and tunnel->hlen are initialized in
> the following way in ip6gre_tnl_link_config():
>
> int addend = sizeof(struct ipv6hdr) + 4;
> ...
> dev->hard_header_len = rt->dst.dev->hard_header_len + addend;
> ...
> t->hlen = addend; // t is ip6_tnl pointer
>
> As you see the information t->hlen is already included in
> dev->hard_header_len, so why calculate it twice?
>
> Thanks
