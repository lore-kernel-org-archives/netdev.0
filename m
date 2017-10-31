From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v2 0/2] bridge: support for vlan to
 tunnel mapping
Date: Tue, 31 Oct 2017 18:06:30 +0100
Message-ID: <20171031180630.3939fba7@shemminger-XPS-13-9360>
References: <1509167630-9869-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:46347 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752177AbdJaRG6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:06:58 -0400
Received: by mail-lf0-f66.google.com with SMTP id g70so19870934lfl.3
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 10:06:58 -0700 (PDT)
In-Reply-To: <1509167630-9869-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Oct 2017 22:13:48 -0700
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
> v2 - rebase to latest net-next
> 
>  bridge/link.c            |  12 ++
>  bridge/vlan.c            | 305 ++++++++++++++++++++++++++++++++++++++++++-----
>  ip/iplink_bridge_slave.c |   9 ++
>  man/man8/bridge.8        |  12 +-
>  man/man8/ip-link.8.in    |   5 +
>  5 files changed, 315 insertions(+), 28 deletions(-)
> 

Applied to net-next
