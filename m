From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 9/9] [NET]: Move netlink interface bits to linux/if.h
Date: Sat, 05 Aug 2006 22:42:18 -0700
Message-ID: <44D5813A.1070309@osdl.org>
References: <20060805003452.493542515@postel.suug.ch> <20060805003538.106022871@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:33668 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161145AbWHEFmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2006 01:42:32 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060805003538.106022871@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
>
> Index: net-2.6.19/include/linux/if.h
> ===================================================================
> --- net-2.6.19.orig/include/linux/if.h
> +++ net-2.6.19/include/linux/if.h
> @@ -212,5 +212,134 @@ struct ifconf 
>  #define	ifc_buf	ifc_ifcu.ifcu_buf		/* buffer address	*/
>  #define	ifc_req	ifc_ifcu.ifcu_req		/* array of structures	*/
>  
> +/* The struct should be in sync with struct net_device_stats */
> +struct rtnl_link_stats
> +{
> +	__u32	rx_packets;		/* total packets received	*/
> +	__u32	tx_packets;		/* total packets transmitted	*/
> +	__u32	rx_bytes;		/* total bytes received 	*/
> +	__u32	tx_bytes;		/* total bytes transmitted	*/
> +	__u32	rx_errors;		/* bad packets received		*/
> +	__u32	tx_errors;		/* packet transmit problems	*/
> +	__u32	rx_dropped;		/* no space in linux buffers	*/
> +	__u32	tx_dropped;		/* no space available in linux	*/
> +	__u32	multicast;		/* multicast packets received	*/
> +	__u32	collisions;
> +
> +	/* detailed rx_errors: */
> +	__u32	rx_length_errors;
> +	__u32	rx_over_errors;		/* receiver ring buff overflow	*/
> +	__u32	rx_crc_errors;		/* recved pkt with crc error	*/
> +	__u32	rx_frame_errors;	/* recv'd frame alignment error */
> +	__u32	rx_fifo_errors;		/* recv'r fifo overrun		*/
> +	__u32	rx_missed_errors;	/* receiver missed packet	*/
> +
> +	/* detailed tx_errors */
> +	__u32	tx_aborted_errors;
> +	__u32	tx_carrier_errors;
> +	__u32	tx_fifo_errors;
> +	__u32	tx_heartbeat_errors;
> +	__u32	tx_window_errors;
> +
> +	/* for cslip etc */
> +	__u32	rx_compressed;
> +	__u32	tx_compressed;
> +};
> +
> +/* The struct should be in sync with struct ifmap */
> +struct rtnl_link_ifmap
> +{
> +	__u64	mem_start;
> +	__u64	mem_end;
> +	__u64	base_addr;
> +	__u16	irq;
> +	__u8	dma;
> +	__u8	port;
> +};
> +
> +enum
> +{
> +	IFLA_UNSPEC,
> +	IFLA_ADDRESS,
> +	IFLA_BROADCAST,
> +	IFLA_IFNAME,
> +	IFLA_MTU,
> +	IFLA_LINK,
> +	IFLA_QDISC,
> +	IFLA_STATS,
> +	IFLA_COST,
> +#define IFLA_COST IFLA_COST
> +	IFLA_PRIORITY,
> +#define IFLA_PRIORITY IFLA_PRIORITY
> +	IFLA_MASTER,
> +#define IFLA_MASTER IFLA_MASTER
> +	IFLA_WIRELESS,		/* Wireless Extension event - see wireless.h */
> +#define IFLA_WIRELESS IFLA_WIRELESS
> +	IFLA_PROTINFO,		/* Protocol specific information for a link */
> +#define IFLA_PROTINFO IFLA_PROTINFO
> +	IFLA_TXQLEN,
> +#define IFLA_TXQLEN IFLA_TXQLEN
> +	IFLA_MAP,
> +#define IFLA_MAP IFLA_MAP
> +	IFLA_WEIGHT,
> +#define IFLA_WEIGHT IFLA_WEIGHT
> +	IFLA_OPERSTATE,
> +	IFLA_LINKMODE,
> +	__IFLA_MAX
> +};
> +
> +
> +#define IFLA_MAX (__IFLA_MAX - 1)
> +
> +/* ifi_flags.
> +
> +   IFF_* flags.
> +
> +   The only change is:
> +   IFF_LOOPBACK, IFF_BROADCAST and IFF_POINTOPOINT are
> +   more not changeable by user. They describe link media
> +   characteristics and set by device driver.
> +
> +   Comments:
> +   - Combination IFF_BROADCAST|IFF_POINTOPOINT is invalid
> +   - If neither of these three flags are set;
> +     the interface is NBMA.
> +
> +   - IFF_MULTICAST does not mean anything special:
> +   multicasts can be used on all not-NBMA links.
> +   IFF_MULTICAST means that this media uses special encapsulation
> +   for multicast frames. Apparently, all IFF_POINTOPOINT and
> +   IFF_BROADCAST devices are able to use multicasts too.
> + */
> +
> +/* IFLA_LINK.
> +   For usual devices it is equal ifi_index.
> +   If it is a "virtual interface" (f.e. tunnel), ifi_link
> +   can point to real physical interface (f.e. for bandwidth calculations),
> +   or maybe 0, what means, that real media is unknown (usual
> +   for IPIP tunnels, when route to endpoint is allowed to change)
> + */
> +
> +/* Subtype attributes for IFLA_PROTINFO */
> +enum
> +{
> +	IFLA_INET6_UNSPEC,
> +	IFLA_INET6_FLAGS,	/* link flags			*/
> +	IFLA_INET6_CONF,	/* sysctl parameters		*/
> +	IFLA_INET6_STATS,	/* statistics			*/
> +	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
> +	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
> +	__IFLA_INET6_MAX
> +};
> +
> +#define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
> +
> +struct ifla_cacheinfo
> +{
> +	__u32	max_reasm_len;
> +	__u32	tstamp;		/* ipv6InterfaceTable updated timestamp */
> +	__u32	reachable_time;
> +	__u32	retrans_time;
> +};
>  
>  #endif /* _LINUX_IF_H */
> Index: net-2.6.19/include/linux/rtnetlink.h
> ===================================================================
> --- net-2.6.19.orig/include/linux/rtnetlink.h
> +++ net-2.6.19/include/linux/rtnetlink.h
> @@ -2,6 +2,7 @@
>  #define __LINUX_RTNETLINK_H
>  
>  #include <linux/netlink.h>
> +#include <linux/if.h>
>  
>  /****
>   *		Routing/neighbour discovery messages.
> @@ -607,138 +608,6 @@ struct prefix_cacheinfo
>  	__u32	valid_time;
>  };
>  
> -/* The struct should be in sync with struct net_device_stats */
> -struct rtnl_link_stats
> -{
> -	__u32	rx_packets;		/* total packets received	*/
> -	__u32	tx_packets;		/* total packets transmitted	*/
> -	__u32	rx_bytes;		/* total bytes received 	*/
> -	__u32	tx_bytes;		/* total bytes transmitted	*/
>   

Make the packets and byte counts __u64 so if/when we extend net_device 
stats to bigger
values, the message format doesn't have to change.
> -	__u32	rx_errors;		/* bad packets received		*/
> -	__u32	tx_errors;		/* packet transmit problems	*/
> -	__u32	rx_dropped;		/* no space in linux buffers	*/
> -	__u32	tx_dropped;		/* no space available in linux	*/
> -	__u32	multicast;		/* multicast packets received	*/
> -	__u32	collisions;
> -
> -	/* detailed rx_errors: */
> -	__u32	rx_length_errors;
> -	__u32	rx_over_errors;		/* receiver ring buff overflow	*/
> -	__u32	rx_crc_errors;		/* recved pkt with crc error	*/
> -	__u32	rx_frame_errors;	/* recv'd frame alignment error */
> -	__u32	rx_fifo_errors;		/* recv'r fifo overrun		*/
> -	__u32	rx_missed_errors;	/* receiver missed packet	*/
> -
> -	/* detailed tx_errors */
> -	__u32	tx_aborted_errors;
> -	__u32	tx_carrier_errors;
> -	__u32	tx_fifo_errors;
> -	__u32	tx_heartbeat_errors;
> -	__u32	tx_window_errors;
> -	
> -	/* for cslip etc */
> -	__u32	rx_compressed;
> -	__u32	tx_compressed;
> -};
> -
> -/* The struct should be in sync with struct ifmap */
> -struct rtnl_link_ifmap
> -{
> -	__u64	mem_start;
> -	__u64	mem_end;
> -	__u64	base_addr;
> -	__u16	irq;
> -	__u8	dma;
> -	__u8	port;
> -};
> -
> -enum
> -{
> -	IFLA_UNSPEC,
> -	IFLA_ADDRESS,
> -	IFLA_BROADCAST,
> -	IFLA_IFNAME,
> -	IFLA_MTU,
> -	IFLA_LINK,
> -	IFLA_QDISC,
> -	IFLA_STATS,
> -	IFLA_COST,
> -#define IFLA_COST IFLA_COST
> -	IFLA_PRIORITY,
> -#define IFLA_PRIORITY IFLA_PRIORITY
> -	IFLA_MASTER,
> -#define IFLA_MASTER IFLA_MASTER
> -	IFLA_WIRELESS,		/* Wireless Extension event - see wireless.h */
> -#define IFLA_WIRELESS IFLA_WIRELESS
> -	IFLA_PROTINFO,		/* Protocol specific information for a link */
> -#define IFLA_PROTINFO IFLA_PROTINFO
> -	IFLA_TXQLEN,
> -#define IFLA_TXQLEN IFLA_TXQLEN
> -	IFLA_MAP,
> -#define IFLA_MAP IFLA_MAP
> -	IFLA_WEIGHT,
> -#define IFLA_WEIGHT IFLA_WEIGHT
> -	IFLA_OPERSTATE,
> -	IFLA_LINKMODE,
> -	__IFLA_MAX
> -};
> -
> -
> -#define IFLA_MAX (__IFLA_MAX - 1)
> -
> -#define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
> -#define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
> -
> -/* ifi_flags.
> -
> -   IFF_* flags.
> -
> -   The only change is:
> -   IFF_LOOPBACK, IFF_BROADCAST and IFF_POINTOPOINT are
> -   more not changeable by user. They describe link media
> -   characteristics and set by device driver.
> -
> -   Comments:
> -   - Combination IFF_BROADCAST|IFF_POINTOPOINT is invalid
> -   - If neither of these three flags are set;
> -     the interface is NBMA.
> -
> -   - IFF_MULTICAST does not mean anything special:
> -   multicasts can be used on all not-NBMA links.
> -   IFF_MULTICAST means that this media uses special encapsulation
> -   for multicast frames. Apparently, all IFF_POINTOPOINT and
> -   IFF_BROADCAST devices are able to use multicasts too.
> - */
> -
> -/* IFLA_LINK.
> -   For usual devices it is equal ifi_index.
> -   If it is a "virtual interface" (f.e. tunnel), ifi_link
> -   can point to real physical interface (f.e. for bandwidth calculations),
> -   or maybe 0, what means, that real media is unknown (usual
> -   for IPIP tunnels, when route to endpoint is allowed to change)
> - */
> -
> -/* Subtype attributes for IFLA_PROTINFO */
> -enum
> -{
> -	IFLA_INET6_UNSPEC,
> -	IFLA_INET6_FLAGS,	/* link flags			*/
> -	IFLA_INET6_CONF,	/* sysctl parameters		*/
> -	IFLA_INET6_STATS,	/* statistics			*/
> -	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
> -	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
> -	__IFLA_INET6_MAX
> -};
> -
> -#define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
> -
> -struct ifla_cacheinfo
> -{
> -	__u32	max_reasm_len;
> -	__u32	tstamp;		/* ipv6InterfaceTable updated timestamp */
> -	__u32	reachable_time;
> -	__u32	retrans_time;
> -};
>  
>  /*****************************************************************
>   *		Traffic control messages.
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

