From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: bridge/brctl/ip
Date: Sun, 3 Apr 2016 00:50:48 +0200
Message-ID: <57004CC8.1080006@cumulusnetworks.com>
References: <57001CFF.20508@biot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Bert Vermeulen <bert@biot.com>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33620 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbcDBWuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 18:50:51 -0400
Received: by mail-lb0-f174.google.com with SMTP id u8so109127143lbk.0
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 15:50:50 -0700 (PDT)
In-Reply-To: <57001CFF.20508@biot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/2016 09:26 PM, Bert Vermeulen wrote:
> Hi all,
> 
> I'm wondering about the current userspace toolset to control bridging in
> the Linux kernel. As far as I can determine, functionality is a bit
> scattered right now between the iproute2 (ip, bridge) and bridge-utils
> (brctl) tools:
> 
> - creating/deleting bridges: ip or brctl
> - adding/deleting ports to/from bridge: brctl only

ip link set dev ethX master bridgeY
ip link set dev ethX nomaster

> - showing bridge fdb: brctl (in-kernel fdb), bridge (hardware offloaded
>   fdb) (!)

bridge fdb show - shows all fdb entries, offloaded or not.

> ...and no doubt a few other things.
> 
> Also the brctl tool seems not to be getting updates, whereas the
> iproute2 tools are of course updated regularly. Is brctl considered
> obsolete?

iproute2 supports (almost, user-space stp?) everything now, there have been many recent
additions to the options that can be manipulated.
$ ip link set dev bridge0 type bridge help
Usage: ... bridge [ forward_delay FORWARD_DELAY ]
                  [ hello_time HELLO_TIME ]
                  [ max_age MAX_AGE ]
                  [ ageing_time AGEING_TIME ]
                  [ stp_state STP_STATE ]
                  [ priority PRIORITY ]
                  [ group_fwd_mask MASK ]
                  [ group_address ADDRESS ]
                  [ vlan_filtering VLAN_FILTERING ]
                  [ vlan_protocol VLAN_PROTOCOL ]
                  [ vlan_default_pvid VLAN_DEFAULT_PVID ]
                  [ mcast_snooping MULTICAST_SNOOPING ]
                  [ mcast_router MULTICAST_ROUTER ]
                  [ mcast_query_use_ifaddr MCAST_QUERY_USE_IFADDR ]
                  [ mcast_querier MULTICAST_QUERIER ]
                  [ mcast_hash_elasticity HASH_ELASTICITY ]
                  [ mcast_hash_max HASH_MAX ]
                  [ mcast_last_member_count LAST_MEMBER_COUNT ]
                  [ mcast_startup_query_count STARTUP_QUERY_COUNT ]
                  [ mcast_last_member_interval LAST_MEMBER_INTERVAL ]
                  [ mcast_membership_interval MEMBERSHIP_INTERVAL ]
                  [ mcast_querier_interval QUERIER_INTERVAL ]
                  [ mcast_query_interval QUERY_INTERVAL ]
                  [ mcast_query_response_interval QUERY_RESPONSE_INTERVAL ]
                  [ mcast_startup_query_interval STARTUP_QUERY_INTERVAL ]
                  [ nf_call_iptables NF_CALL_IPTABLES ]
                  [ nf_call_ip6tables NF_CALL_IP6TABLES ]
                  [ nf_call_arptables NF_CALL_ARPTABLES ]

Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }


> 
> If that is the case, would patches to add the missing functionality into
> the bridge tool be welcome? I'm thinking primarily of creating/deleting
> bridges, and adding/deleting ports in bridges.
> 
> 
