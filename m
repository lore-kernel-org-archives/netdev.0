From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH net-next v2 00/12] openvswitch: gre tunneling support.
Date: Tue, 18 Jun 2013 18:27:40 +0800
Message-ID: <CAEH94LioY_xkgfUzBQHnqEqEC-8K07Aiuvn03oKuhaMegcm--Q@mail.gmail.com>
References: <1371516561-17622-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f46.google.com ([209.85.128.46]:56592 "EHLO
	mail-qe0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050Ab3FRK1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 06:27:40 -0400
Received: by mail-qe0-f46.google.com with SMTP id nd7so2285866qeb.5
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 03:27:40 -0700 (PDT)
In-Reply-To: <1371516561-17622-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI,

  Do you have one git tree for this patchset? I would like to play
with it and do some tests.

On Tue, Jun 18, 2013 at 8:49 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch series adds support for gre tunneling.
> First six patches extend kernel gre and ip_tunnel modules
> api so that there is more code sharing between gre modules
> and ovs. Rest of patches adds ovs tunneling infrastructre
> and gre protocol vport.
>
> V2 fixes two patches according to comments from Jesse.
>
> Pravin B Shelar (12):
>   gre: Simplify gre protocol registration locking.
>   gre: Allow multiple protocol listener for gre protocol.
>   gre: export gre_build_header() function.
>   gre: export gre_handle_offloads() function.
>   ip_tunnels: extend iptunnel_xmit()
>   ip_tunnel: push generic protocol handling to ip_tunnel module.
>   ip_tunnel: Add dont fragment flag.
>   openvswitch: Copy individual actions.
>   openvswitch: Add tunneling interface.
>   openvswitch: Expand action buffer size.
>   openvswitch: Optimize flow key match for non tunnel flows.
>   openvswitch: Add gre tunnel support.
>
>  drivers/net/vxlan.c                  |   32 +---
>  include/net/gre.h                    |   27 +++
>  include/net/ip_tunnels.h             |   28 ++-
>  include/uapi/linux/openvswitch.h     |   19 ++
>  net/ipv4/Makefile                    |    2 +-
>  net/ipv4/gre.c                       |  323 ++++++++++++++++++++++++++++---
>  net/ipv4/ip_gre.c                    |  247 +++---------------------
>  net/ipv4/ip_tunnel.c                 |   68 ++-----
>  net/ipv4/ip_tunnel_core.c            |  121 ++++++++++++
>  net/ipv4/ipip.c                      |    6 +-
>  net/ipv6/sit.c                       |   44 ++---
>  net/openvswitch/Makefile             |    3 +-
>  net/openvswitch/actions.c            |    4 +
>  net/openvswitch/datapath.c           |  356 ++++++++++++++++++++++++++++------
>  net/openvswitch/datapath.h           |    4 +
>  net/openvswitch/flow.c               |  186 ++++++++++++++++--
>  net/openvswitch/flow.h               |   45 ++++-
>  net/openvswitch/vport-gre.c          |  274 ++++++++++++++++++++++++++
>  net/openvswitch/vport-internal_dev.c |    2 +-
>  net/openvswitch/vport-netdev.c       |    2 +-
>  net/openvswitch/vport.c              |   23 ++-
>  net/openvswitch/vport.h              |   10 +-
>  22 files changed, 1370 insertions(+), 456 deletions(-)
>  create mode 100644 net/ipv4/ip_tunnel_core.c
>  create mode 100644 net/openvswitch/vport-gre.c
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
Regards,

Zhi Yong Wu
