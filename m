From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 V4 0/3] tc: Support for ip tunnel metadata
 set/unset/classify
Date: Thu, 1 Dec 2016 10:54:25 -0800
Message-ID: <20161201105425.2a068555@xeon-e3>
References: <20161201114446.30333-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33668 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755160AbcLASya (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 13:54:30 -0500
Received: by mail-pg0-f49.google.com with SMTP id 3so97851738pgd.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 10:54:28 -0800 (PST)
In-Reply-To: <20161201114446.30333-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 Dec 2016 13:44:43 +0200
Amir Vadai <amir@vadai.me> wrote:

> Hi,
> 
> This short series adds support for matching and setting metadata for ip tunnel
> shared device using the TC system, introduced in kernel 4.9 [1].
> 
> Applied and tested on top of commit f3f339e9590a ("cleanup debris from revert")
> 
> Example usage:
> 
> $ tc filter add dev vxlan0 protocol ip parent ffff: \
>     flower \
>       enc_src_ip 11.11.0.2 \
>       enc_dst_ip 11.11.0.1 \
>       enc_key_id 11 \
>       dst_ip 11.11.11.1 \
>     action mirred egress redirect dev vnet0
> 
> $ tc filter add dev net0 protocol ip parent ffff: \
>     flower \
>       ip_proto 1 \
>       dst_ip 11.11.11.2 \
>     action tunnel_key set \
>       src_ip 11.11.0.1 \
>       dst_ip 11.11.0.2 \
>       id 11 \
>     action mirred egress redirect dev vxlan0
> 
> [1] - d1ba24feb466 ("Merge branch 'act_tunnel_key'")
> 
> Thanks,
> Amir
> 
> Changes from V3:
> - Fix bad wording in the man page about the use of the 'unset' operation
> 
> Changes from V2:
> - Use const where needed
> - Don't lose return value
> - Introduce rta_getattr_be16() and rta_getattr_be32()
> 
> Changes from V1:
> - Updated Patch 2/2 ("tc/act_tunnel: Introduce ip tunnel action") commit log
> 	and the man page tc-tunnel_key to reflect the fact that 'unset' operation is
> 	no mandatory.
> 	And describe when it might be needed.
> - Rename the 'release' operation to 'unset'
> 
> Amir Vadai (3):
>   libnetlink: Introduce rta_getattr_be*()
>   tc/cls_flower: Classify packet in ip tunnels
>   tc/act_tunnel: Introduce ip tunnel action
> 
>  bridge/fdb.c                         |   4 +-
>  include/libnetlink.h                 |   9 ++
>  include/linux/tc_act/tc_tunnel_key.h |  42 ++++++
>  ip/iplink_geneve.c                   |   2 +-
>  ip/iplink_vxlan.c                    |   2 +-
>  man/man8/tc-flower.8                 |  17 ++-
>  man/man8/tc-tunnel_key.8             | 112 +++++++++++++++
>  tc/Makefile                          |   1 +
>  tc/f_flower.c                        |  84 +++++++++++-
>  tc/m_tunnel_key.c                    | 258 +++++++++++++++++++++++++++++++++++
>  10 files changed, 522 insertions(+), 9 deletions(-)
>  create mode 100644 include/linux/tc_act/tc_tunnel_key.h
>  create mode 100644 man/man8/tc-tunnel_key.8
>  create mode 100644 tc/m_tunnel_key.c

I cleared up patch backlog and got net-next branch up to date with kernel
headers, and this patch series does not apply cleanly anymore.

Please rebase and resubmit.
