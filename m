From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] doc: update Documentation/sysctl/net.txt
Date: Mon, 13 Apr 2009 13:20:40 -0700 (PDT)
Message-ID: <20090413.132040.262391712.davem@davemloft.net>
References: <49E2FE5B.9090908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: shen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50163
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751029AbZDMUUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 16:20:50 -0400
In-Reply-To: <49E2FE5B.9090908@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shen Feng <shen@cn.fujitsu.com>
Date: Mon, 13 Apr 2009 16:56:59 +0800

Please always CC: netdev@vger.kernel.org on networking patches
so that they get properly tracked at:

	http://patchwork.ozlabs.org/project/netdev/list/

Thank you.

> Update Documentation/sysctl/net.txt with the kernel 2.6.29. Move
> some of the file discriptions from ip-sysctl.txt to net.txt.
> ip-sysctl.txt only describes the INET(6) parameters.
> net.txt describes all of the net parameters.
> 
> Signed-off-by: Shen Feng <shen@cn.fujitsu.com>
> ---
>  Documentation/networking/ip-sysctl.txt |   25 ---------
>  Documentation/sysctl/net.txt           |   89 +++++++++++++++++++++++++++-----
>  2 files changed, 76 insertions(+), 38 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index ec5de02..4b7381e 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -107,11 +107,6 @@ inet_peer_gc_maxtime - INTEGER
>  
>  TCP variables:
>  
> -somaxconn - INTEGER
> -	Limit of socket listen() backlog, known in userspace as SOMAXCONN.
> -	Defaults to 128.  See also tcp_max_syn_backlog for additional tuning
> -	for TCP sockets.
> -
>  tcp_abc - INTEGER
>  	Controls Appropriate Byte Count (ABC) defined in RFC3465.
>  	ABC is a way of increasing congestion window (cwnd) more slowly
> @@ -1266,23 +1261,3 @@ sctp_rmem - vector of 3 INTEGERs: min, default, max
>  sctp_wmem  - vector of 3 INTEGERs: min, default, max
>  	See tcp_wmem for a description.
>  
> -UNDOCUMENTED:
> -
> -/proc/sys/net/core/*
> -	dev_weight FIXME
> -
> -/proc/sys/net/unix/*
> -	max_dgram_qlen FIXME
> -
> -/proc/sys/net/irda/*
> -	fast_poll_increase FIXME
> -	warn_noreply_time FIXME
> -	discovery_slots FIXME
> -	slot_timeout FIXME
> -	max_baud_rate FIXME
> -	discovery_timeout FIXME
> -	lap_keepalive_time FIXME
> -	max_noreply_time FIXME
> -	max_tx_data_size FIXME
> -	max_tx_window FIXME
> -	min_tx_turn_time FIXME
> diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
> index a34d55b..c675e4c 100644
> --- a/Documentation/sysctl/net.txt
> +++ b/Documentation/sysctl/net.txt
> @@ -1,4 +1,4 @@
> -Documentation for /proc/sys/net/*	kernel version 2.4.0-test11-pre4
> +Documentation for /proc/sys/net/*	kernel version 2.6.29
>  	(c) 1999		Terrehon Bowden <terrehon@pacbell.net>
>  				Bodo Bauer <bb@ricochet.net>
>  	(c) 2000		Jorge Nerin <comandante@zaralinux.com>
> @@ -9,7 +9,7 @@ For general info and legal blurb, please look in README.
>  ==============================================================
>  
>  This file contains the documentation for the sysctl files in
> -/proc/sys/net and is valid for Linux kernel version 2.4.0-test11-pre4.
> +/proc/sys/net and is valid for Linux kernel version 2.6.29.
>  
>  The interface  to  the  networking  parts  of  the  kernel  is  located  in
>  /proc/sys/net. The following table shows all possible subdirectories.You may
> @@ -26,7 +26,8 @@ Table : Subdirectories in /proc/sys/net
>   ipv4      IP version 4        x25        X.25 protocol
>   ipx       IPX                 token-ring IBM token ring
>   bridge    Bridging            decnet     DEC net
> - ipv6      IP version 6
> + ipv6      IP version 6        sctp       SCTP protocol
> + irda      IrDA protocol
>  ..............................................................................
>  
>  1. /proc/sys/net/core - Network core options
> @@ -40,17 +41,17 @@ The default setting of the socket receive buffer in bytes.
>  rmem_max
>  --------
>  
> -The maximum receive socket buffer size in bytes.
> +The maximum socket receive buffer size in bytes.
>  
>  wmem_default
>  ------------
>  
> -The default setting (in bytes) of the socket send buffer.
> +The default setting of the socket send buffer in bytes.
>  
>  wmem_max
>  --------
>  
> -The maximum send socket buffer size in bytes.
> +The maximum socket send buffer size in bytes.
>  
>  message_burst and message_cost
>  ------------------------------
> @@ -90,21 +91,42 @@ optmem_max
>  Maximum ancillary buffer size allowed per socket. Ancillary data is a sequence
>  of struct cmsghdr structures with appended data.
>  
> +dev_weight
> +----------
> +
> +FIXME.
> +
> +somaxconn - INTEGER
> +----------
> +
> +Limit of socket listen() backlog, known in userspace as SOMAXCONN. Defaults to
> +128.  See also ipv4/tcp_max_syn_backlog for additional tuning for TCP sockets.
> +
> +xfrm_*
> +----------
> +
> +Please see: Documentation/networking/xfrm_sysctl.txt for descriptions of these
> +entries.
> +
> +
>  2. /proc/sys/net/unix - Parameters for Unix domain sockets
>  -------------------------------------------------------
>  
> -There is only one file in this directory.
> -unix_dgram_qlen limits the max number of datagrams queued in Unix domain
> -socket's buffer. It will not take effect unless PF_UNIX flag is spicified.
> +unix_dgram_qlen
> +----------
> +
> +Limit of the max number of datagrams queued in Unix domain socket buffer.
> +It will not take effect unless PF_UNIX flag is specified.
>  
>  
>  3. /proc/sys/net/ipv4 - IPV4 settings
>  -------------------------------------------------------
> +
>  Please see: Documentation/networking/ip-sysctl.txt and ipvs-sysctl.txt for
>  descriptions of these entries.
>  
>  
> -4. Appletalk
> +4. /proc/sys/net/appletalk - Appletalk settings
>  -------------------------------------------------------
>  
>  The /proc/sys/net/appletalk  directory  holds the Appletalk configuration data
> @@ -149,12 +171,15 @@ interface.
>  route flags, and the device the route is using.
>  
>  
> -5. IPX
> +5. /proc/sys/net/ipx/ - IPX settings
>  -------------------------------------------------------
>  
> -The IPX protocol has no tunable values in proc/sys/net.
> +ipx_pprop_broadcasting
> +---------------------
> +
> +FIXME.
>  
> -The IPX  protocol  does,  however,  provide  proc/net/ipx. This lists each IPX
> +The IPX  protocol  does,  however,  provide /proc/net/ipx. This lists each IPX
>  socket giving  the  local  and  remote  addresses  in  Novell  format (that is
>  network:node:port). In  accordance  with  the  strange  Novell  tradition,
>  everything but the port is in hex. Not_Connected is displayed for sockets that
> @@ -173,3 +198,41 @@ IPX.
>  The /proc/net/ipx_route  table  holds  a list of IPX routes. For each route it
>  gives the  destination  network, the router node (or Directly) and the network
>  address of the router (or Connected) for internal networks.
> +
> +
> +6. /proc/sys/net/ipv6 - IPV6 settings
> +-------------------------------------------------------
> +
> +Please see: Documentation/networking/ip-sysctl.txt for descriptions of these
> +entries.
> +
> +
> +7. /proc/sys/net/sctp  - SCTP settings
> +-------------------------------------------------------
> +
> +Please see: Documentation/networking/ip-sysctl.txt for descriptions of these
> +entries.
> +
> +
> +8. /proc/sys/net/bridge
> +-------------------------------------------------------
> +
> +Please see: Documentation/networking/ip-sysctl.txt for descriptions of these
> +entries.
> +
> +
> +9. /proc/sys/net/irda
> +-------------------------------------------------------
> +
> +	fast_poll_increase FIXME
> +	warn_noreply_time FIXME
> +	discovery_slots FIXME
> +	slot_timeout FIXME
> +	max_baud_rate FIXME
> +	discovery_timeout FIXME
> +	lap_keepalive_time FIXME
> +	max_noreply_time FIXME
> +	max_tx_data_size FIXME
> +	max_tx_window FIXME
> +	min_tx_turn_time FIXME
> +
> -- 
> 1.6.0.6
> 
> 
> 
