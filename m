From: Andy Zhou <azhou@nicira.com>
Subject: Re: [v8 net-next 0/4] Refactor vxlan and l2tp to use new common UDP
 tunnel APIs
Date: Tue, 16 Sep 2014 17:43:46 -0700
Message-ID: <CACzMAJLNQWHhEovZKUXUqbQ-vkpV_4pg3NBvnFQMGZ6d5cy7_w@mail.gmail.com>
References: <1410913787-31599-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:43688 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754400AbaIQAnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 20:43:47 -0400
Received: by mail-oa0-f48.google.com with SMTP id g18so544952oah.21
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 17:43:46 -0700 (PDT)
In-Reply-To: <1410913787-31599-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forgot to mention there is no code from v7-v8, just added more content
to the commit message.

Should have added the following line to the commit message:

v7->v8:  commit message enhancement.

On Tue, Sep 16, 2014 at 5:29 PM, Andy Zhou <azhou@nicira.com> wrote:
> This patch series add a few more UDP tunnel APIs and refactoring current
> UDP tunnel based protocols, vxlan and l2tp to make use of the new APIs.
>
> The added APIs are setup_udp_tunnel_sock(), udp_tunnel_xmit_skb() and
> udp_tunnel_sock_release(). Those implementation logics already exist in
> current vxlan and l2tp implementation. Move them to common APIs to reduce
> code duplications.
>
> Also split udp_tunnel.c into net/ipv4/udp_tunnel.c and
> net/ipv6/ip6_udp_tunnel.c to maintain proper IP protocol separation.
>
> Andy Zhou (4):
>   udp_tunnel: Seperate ipv6 functions into its own file.
>   udp-tunnel: Add a few more UDP tunnel APIs
>   vxlan: Refactor vxlan driver to make use of the common UDP tunnel
>     functions.
>   l2tp: Refactor l2tp core driver to make use of the common UDP tunnel
>     functions
>
>  drivers/net/vxlan.c       |  105 ++++++++--------------------------
>  include/net/udp_tunnel.h  |   85 +++++++++++++++++++++++++++-
>  net/ipv4/udp_tunnel.c     |  138 ++++++++++++++++++++++++---------------------
>  net/ipv6/Makefile         |    1 +
>  net/ipv6/ip6_udp_tunnel.c |  105 ++++++++++++++++++++++++++++++++++
>  net/l2tp/l2tp_core.c      |   24 ++++----
>  6 files changed, 294 insertions(+), 164 deletions(-)
>  create mode 100644 net/ipv6/ip6_udp_tunnel.c
>
> --
> 1.7.9.5
>
