From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 1/2] openvswitch: add tunnel protocol to sw_flow_key
Date: Tue, 29 Sep 2015 13:41:34 -0700
Message-ID: <CALnjE+qWmENWj_hL87++Sk=zzrvj2U0VAEW26ySAjg5RsDymuA@mail.gmail.com>
References: <cover.1443548447.git.jbenc@redhat.com>
	<428cee4cb7e04cfea5bef90b37d257562ea78a83.1443548447.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33742 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbbI2Ulf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 16:41:35 -0400
Received: by iofh134 with SMTP id h134so25126644iof.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 13:41:34 -0700 (PDT)
In-Reply-To: <428cee4cb7e04cfea5bef90b37d257562ea78a83.1443548447.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 10:52 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Store tunnel protocol (AF_INET or AF_INET6) in sw_flow_key. This field now
> also acts as an indicator whether the flow contains tunnel data (this was
> previously indicated by tun_key.u.ipv4.dst being set but with IPv6 addresses
> in an union with IPv4 ones this won't work anymore).
>
> The new field was added to a hole in sw_flow_key.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  net/openvswitch/flow.c         | 4 ++--
>  net/openvswitch/flow.h         | 1 +
>  net/openvswitch/flow_netlink.c | 7 +++++--
>  net/openvswitch/flow_table.c   | 2 +-
>  4 files changed, 9 insertions(+), 5 deletions(-)
>
...

> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index fe527d2dd4b7..5688e33e2de6 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -63,6 +63,7 @@ struct sw_flow_key {
>                 u32     skb_mark;       /* SKB mark. */
>                 u16     in_port;        /* Input switch port (or DP_MAX_PORTS). */
>         } __packed phy; /* Safe when right after 'tun_key'. */
> +       u8 tun_proto;                   /* Protocol of encapsulating tunnel. */

We can add rather add TUNNEL_IPV6 flag to distinguish IPv4 and IPv6
tunnel keys. This can be stored in ip_tunnel_key.tun_flags. That also
saves space in flow key.
