From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [net-next 00/10] Add Geneve
Date: Tue, 22 Jul 2014 16:24:03 +0530
Message-ID: <53CE42CB.1060409@gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:42412 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbaGVKzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:55:21 -0400
Received: by mail-pa0-f46.google.com with SMTP id lj1so11561486pab.19
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:55:21 -0700 (PDT)
In-Reply-To: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 03:49 PM, Andy Zhou wrote:
> Following patches adds initial support for Geneve tunnel protocol
> 1. Add Geneve driver.
> 2. Add common UDP tunnel code into UDP tunnel support function
> 3. Refactor vxlan driver to make use of the UDP tunnel support
> 4. Refactor Openvswitch  in preparation for #5
> 5. Add Geneve support to Openvswitch.
>
> Note: Geneve offload are not supported in this version. We plan to
> post follow on patches that implements them we can verified with
> at least one working NIC that supports Geneve offloading.
>
> Andy Zhou (5):
>    net: Rename ndo_add_vxlan_port to ndo_add_udp_tunnel_port.
>    udp: Expand UDP tunnel common APIs
>    vxlan: Remove vxlan_get_rx_port()
>    net: Refactor vxlan driver to make use of common UDP tunnel functions
>    net: Add Geneve tunneling protocol driver
>
> Jesse Gross (5):
>    openvswitch: Eliminate memset() from flow_extract.
>    openvswitch: Add support for matching on OAM packets.
>    openvswitch: Wrap struct ovs_key_ipv4_tunnel in a new structure.
>    openvswitch: Factor out allocation and verification of actions.
>    openvswitch: Add support for Geneve tunneling.
>
>   drivers/net/ethernet/emulex/benet/be_main.c      |   17 +-
>   drivers/net/ethernet/intel/i40e/i40e_main.c      |   18 +-
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   19 +-
>   drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   19 +-
>   drivers/net/vxlan.c                              |  273 ++++++----------------
>   include/linux/netdevice.h                        |   35 +--
>   include/net/geneve.h                             |   85 +++++++
>   include/net/ip_tunnels.h                         |    2 +
>   include/net/udp_tunnel.h                         |   57 +++++
>   include/net/vxlan.h                              |   21 +-
>   include/uapi/linux/openvswitch.h                 |    5 +-
>   net/ipv4/Kconfig                                 |   14 ++
>   net/ipv4/Makefile                                |    1 +
>   net/ipv4/geneve.c                                |  273 ++++++++++++++++++++++
>   net/ipv4/udp_tunnel.c                            |  257 +++++++++++++++++++-
>   net/openvswitch/Kconfig                          |   11 +
>   net/openvswitch/Makefile                         |    5 +
>   net/openvswitch/actions.c                        |    6 +-
>   net/openvswitch/datapath.c                       |   71 ++++--
>   net/openvswitch/datapath.h                       |    3 +-
>   net/openvswitch/flow.c                           |   62 ++++-
>   net/openvswitch/flow.h                           |   41 +++-
>   net/openvswitch/flow_netlink.c                   |  184 +++++++++++++--
>   net/openvswitch/flow_netlink.h                   |    2 +-
>   net/openvswitch/vport-geneve.c                   |  258 ++++++++++++++++++++
>   net/openvswitch/vport-gre.c                      |   29 +--
>   net/openvswitch/vport-vxlan.c                    |   34 +--
>   net/openvswitch/vport.c                          |    8 +-
>   net/openvswitch/vport.h                          |    3 +-
>   29 files changed, 1457 insertions(+), 356 deletions(-)
>   create mode 100644 include/net/geneve.h
>   create mode 100644 net/ipv4/geneve.c
>   create mode 100644 net/openvswitch/vport-geneve.c
>
check patch warnings and errors are there in this series...


-- 
Regards,
Varka Bhadram.
