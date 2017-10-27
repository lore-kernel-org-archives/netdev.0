From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 0/2] bridge: support for vlan to
 tunnel mapping
Date: Fri, 27 Oct 2017 09:30:26 +0200
Message-ID: <20171027093026.1128c611@shemminger-XPS-13-9360>
References: <1509045367-42793-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:53009 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbdJ0Hao (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 03:30:44 -0400
Received: by mail-wr0-f195.google.com with SMTP id k62so5302633wrc.9
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 00:30:44 -0700 (PDT)
In-Reply-To: <1509045367-42793-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Oct 2017 12:16:05 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This series adds the required options to iplink and bridge commands
> to enable per vlan tunnel info on a bridge port provided by
> netlink attributes IFLA_BRPORT_VLAN_TUNNEL (flag) and
> IFLA_BRIDGE_VLAN_TUNNEL_INFO
> 
> enable vlan-tunnel mapping on a bridge port:
> $ip link set dev vxlan0 type bridge_slave vlan_tunnel on
> $ip link set dev vxlan0 type bridge_slave vlan_tunnel off
> 
> or
> 
> $bridge link set dev vxlan0 vlan_tunnel on
> $bridge link set dev vxlan0 vlan_tunnel off
> 
> add vlan tunnel mapping (expects vlans to have been already
> configured on the port):
> $bridge vlan add dev vxlan0 vid 2000 tunnel_info id 2000
> $bridge vlan add dev vxlan0 vid 1000-1001 tunnel_info id 2000-2001
> 
> $bridge vlan tunnelshow
> port    vlan ids        tunnel id
> vxlan0   1000-1001       1000-1001
>          2000            2000
> 
> $bridge  -j vlan tunnelshow
> {
>     "dummy0": [],
>     "dummy1": [],
>     "bridge": [],
>     "vxlan0": [{
>             "vlan": 1000,
>             "vlanEnd": 1001,
>             "tunid": 1000,
>             "tunidEnd": 1001
>         },{
>             "vlan": 2000,
>             "tunid": 2000
>         }
>     ]
> }
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Roopa Prabhu (2):
>   iplink: bridge: support bridge port vlan_tunnel attribute
>   bridge: vlan: support for per vlan tunnel info
> 
>  bridge/link.c            |  12 ++
>  bridge/vlan.c            | 305 ++++++++++++++++++++++++++++++++++++++++++-----
>  ip/iplink_bridge_slave.c |   9 ++
>  man/man8/bridge.8        |  12 +-
>  man/man8/ip-link.8.in    |   5 +
>  5 files changed, 315 insertions(+), 28 deletions(-)
> 

These patches are fine, but conflict with current net-next tree
where I merged some other vlan info patches.

Please rebase.
