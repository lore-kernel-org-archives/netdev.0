From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 4/5] flow_dissector: Use same pointer for IPv4
 and IPv6 addresses
Date: Wed, 24 Feb 2016 10:15:13 -0800
Message-ID: <CALx6S37wKR7KbVcOSvQHMg3x71Mqqc63-qR=r42rYQJMea8m0Q@mail.gmail.com>
References: <20160224172644.12339.92679.stgit@localhost.localdomain>
	<20160224172957.12339.12061.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34435 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755889AbcBXSPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 13:15:18 -0500
Received: by mail-io0-f176.google.com with SMTP id 9so52558686iom.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 10:15:17 -0800 (PST)
In-Reply-To: <20160224172957.12339.12061.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2016 at 9:29 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> The IPv6 parsing was using a local pointer when it could use the same
> pointer as the IPv4 portion of the code since the key_addrs can support
> both IPv4 and IPv6 as it is just a pointer.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  net/core/flow_dissector.c |   11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
>
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 6288153d7f36..7c7b8739b8b8 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -220,13 +220,12 @@ ipv6:
>
>                 if (dissector_uses_key(flow_dissector,
>                                        FLOW_DISSECTOR_KEY_IPV6_ADDRS)) {
> -                       struct flow_dissector_key_ipv6_addrs *key_ipv6_addrs;
> -
> -                       key_ipv6_addrs = skb_flow_dissector_target(flow_dissector,
> -                                                                  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
> -                                                                  target_container);
> +                       key_addrs = skb_flow_dissector_target(flow_dissector,
> +                                                             FLOW_DISSECTOR_KEY_IPV6_ADDRS,
> +                                                             target_container);
>
> -                       memcpy(key_ipv6_addrs, &iph->saddr, sizeof(*key_ipv6_addrs));
> +                       memcpy(&key_addrs->v6addrs, &iph->saddr,
> +                              sizeof(key_addrs->v6addrs));
>                         key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
>                 }
>
>
