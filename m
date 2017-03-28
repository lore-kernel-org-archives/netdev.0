From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2] man: ip-link.8: document bridge options
Date: Tue, 28 Mar 2017 17:56:48 +0200
Message-ID: <6c2f00608560d073b1f8c727c86feda0240dad49.1490716280.git.sd@queasysnail.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Sabrina Dubroca <sd@queasysnail.net>, Phil Sutter <phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52438 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752309AbdC1P5N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 11:57:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 man/man8/ip-link.8.in | 229 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 229 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 3f5d57c28885..15b32bc6665a 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -990,6 +990,235 @@ corresponds to the 2010 version of the HSR standard. Option "1" activates the
 .in -8
 
 .TP
+BRIDGE Type Support
+For a link of type
+.I BRIDGE
+the following additional arguments are supported:
+
+.BI "ip link add " DEVICE " type bridge "
+[
+.BI ageing_time " AGEING_TIME "
+] [
+.BI group_fwd_mask " MASK "
+] [
+.BI group_address " ADDRESS "
+] [
+.BI forward_delay " FORWARD_DELAY "
+] [
+.BI hello_time " HELLO_TIME "
+] [
+.BI max_age " MAX_AGE "
+] [
+.BI stp_state " STP_STATE "
+] [
+.BI priority " PRIORITY "
+] [
+.BI vlan_filtering " VLAN_FILTERING "
+] [
+.BI vlan_protocol " VLAN_PROTOCOL "
+] [
+.BI vlan_default_pvid " VLAN_DEFAULT_PVID "
+] [
+.BI vlan_stats_enabled " VLAN_STATS_ENABLED "
+] [
+.BI mcast_snooping " MULTICAST_SNOOPING "
+] [
+.BI mcast_router " MULTICAST_ROUTER "
+] [
+.BI mcast_query_use_ifaddr " MCAST_QUERY_USE_IFADDR "
+] [
+.BI mcast_querier " MULTICAST_QUERIER "
+] [
+.BI mcast_hash_elasticity " HASH_ELASTICITY "
+] [
+.BI mcast_hash_max " HASH_MAX "
+] [
+.BI mcast_last_member_count " LAST_MEMBER_COUNT "
+] [
+.BI mcast_startup_query_count " STARTUP_QUERY_COUNT "
+] [
+.BI mcast_last_member_interval " LAST_MEMBER_INTERVAL "
+] [
+.BI mcast_membership_interval " MEMBERSHIP_INTERVAL "
+] [
+.BI mcast_querier_interval " QUERIER_INTERVAL "
+] [
+.BI mcast_query_interval " QUERY_INTERVAL "
+] [
+.BI mcast_query_response_interval " QUERY_RESPONSE_INTERVAL "
+] [
+.BI mcast_startup_query_interval " STARTUP_QUERY_INTERVAL "
+] [
+.BI mcast_stats_enabled " MCAST_STATS_ENABLED "
+] [
+.BI mcast_igmp_version " IGMP_VERSION "
+] [
+.BI mcast_mld_version " MLD_VERSION "
+] [
+.BI nf_call_iptables " NF_CALL_IPTABLES "
+] [
+.BI nf_call_ip6tables " NF_CALL_IP6TABLES "
+] [
+.BI nf_call_arptables " NF_CALL_ARPTABLES "
+]
+
+.in +8
+.sp
+.BI ageing_time " AGEING_TIME "
+- configure the bridge's FDB entries ageing time, ie the number of seconds a MAC address will be kept in the FDB after a packet has been received from that address. after this time has passed, entries are cleaned up.
+
+.BI group_fwd_mask " MASK "
+- set the group forward mask. This is the bitmask that is applied to decide whether to forward incoming frames destined to link-local addresses, ie addresses of the form 01:80:C2:00:00:0X (defaults to 0, ie the bridge does not forward any link-local frames).
+
+.BI group_address " ADDRESS "
+- set the MAC address of the multicast group this bridge uses for STP.  The address must be a link-local address in standard Ethernet MAC address format, ie an address of the form 01:80:C2:00:00:0X, with X in [0, 4..f].
+
+.BI forward_delay " FORWARD_DELAY "
+- set the forwarding delay in seconds, ie the time spent in LISTENING state (before moving to LEARNING) and in LEARNING state (before moving to FORWARDING). Only relevant if STP is enabled. Valid values are between 2 and 30.
+
+.BI hello_time " HELLO_TIME "
+- set the time in seconds between hello packets sent by the bridge, when it is a root bridge or a designated bridges. Only relevant if STP is enabled. Valid values are between 1 and 10.
+
+.BI max_age " MAX_AGE "
+- set the hello packet timeout, ie the time in seconds until another bridge in the spanning tree is assumed to be dead, after reception of its last hello message. Only relevant if STP is enabled. Valid values are between 6 and 40.
+
+.BI stp_state " STP_STATE "
+- turn spanning tree protocol on
+.RI ( STP_STATE " > 0) "
+or off
+.RI ( STP_STATE " == 0). "
+for this bridge.
+
+.BI priority " PRIORITY "
+- set this bridge's spanning tree priority, used during STP root bridge election.
+.I PRIORITY
+is a 16bit unsigned integer.
+
+.BI vlan_filtering " VLAN_FILTERING "
+- turn VLAN filtering on
+.RI ( VLAN_FILTERING " > 0) "
+or off
+.RI ( VLAN_FILTERING " == 0). "
+When disabled, the bridge will not consider the VLAN tag when handling packets.
+
+.BR vlan_protocol " { " 802.1Q " | " 802.1ad " } "
+- set the protocol used for VLAN filtering.
+
+.BI vlan_default_pvid " VLAN_DEFAULT_PVID "
+- set the default PVID (native/untagged VLAN ID) for this bridge.
+
+.BI vlan_stats_enabled " VLAN_STATS_ENABLED "
+- enable
+.RI ( VLAN_STATS_ENABLED " == 1) "
+or disable
+.RI ( VLAN_STATS_ENABLED " == 0) "
+per-VLAN stats accounting.
+
+.BI mcast_snooping " MULTICAST_SNOOPING "
+- turn multicast snooping on
+.RI ( MULTICAST_SNOOPING " > 0) "
+or off
+.RI ( MULTICAST_SNOOPING " == 0). "
+
+.BI mcast_router " MULTICAST_ROUTER "
+- set bridge's multicast router if IGMP snooping is enabled.
+.I MULTICAST_ROUTER
+is an integer value having the following meaning:
+.in +8
+.sp
+.B 0
+- disabled.
+
+.B 1
+- automatic (queried).
+
+.B 2
+- permanently enabled.
+.in -8
+
+.BI mcast_query_use_ifaddr " MCAST_QUERY_USE_IFADDR "
+- whether to use the bridge's own IP address as source address for IGMP queries
+.RI ( MCAST_QUERY_USE_IFADDR " > 0) "
+or the default of 0.0.0.0
+.RI ( MCAST_QUERY_USE_IFADDR " == 0). "
+
+.BI mcast_querier " MULTICAST_QUERIER "
+- enable
+.RI ( MULTICAST_QUERIER " > 0) "
+or disable
+.RI ( MULTICAST_QUERIER " == 0) "
+IGMP querier, ie sending of multicast queries by the bridge (default: disabled).
+
+.BI mcast_querier_interval " QUERIER_INTERVAL "
+- interval between queries sent by other routers. if no queries are seen after this delay has passed, the bridge will start to send its own queries (as if
+.BI mcast_querier
+was enabled).
+
+.BI mcast_hash_elasticity " HASH_ELASTICITY "
+- set multicast database hash elasticity, ie the maximum chain length in the multicast hash table (defaults to 4).
+
+.BI mcast_hash_max " HASH_MAX "
+- set maximum size of multicast hash table (defaults to 512, value must be a power of 2).
+
+.BI mcast_last_member_count " LAST_MEMBER_COUNT "
+- set multicast last member count, ie the number of queries the bridge will send before stopping forwarding a multicast group after a "leave" message has been received (defaults to 2).
+
+.BI mcast_last_member_interval " LAST_MEMBER_INTERVAL "
+- interval between queries to find remaining members of a group, after a "leave" message is received.
+
+.BI mcast_startup_query_count " STARTUP_QUERY_COUNT "
+- set the number of IGMP queries to send during startup phase (defaults to 2).
+
+.BI mcast_startup_query_interval " STARTUP_QUERY_INTERVAL "
+- interval between queries in the startup phase.
+
+.BI mcast_query_interval " QUERY_INTERVAL "
+- interval between queries sent by the bridge after the end of the startup phase.
+
+.BI mcast_query_response_interval " QUERY_RESPONSE_INTERVAL "
+- set the Max Response Time/Maximum Response Delay for IGMP/MLD queries sent by the bridge.
+
+.BI mcast_membership_interval " MEMBERSHIP_INTERVAL "
+- delay after which the bridge will leave a group, if no membership reports for this group are received.
+
+.BI mcast_stats_enabled " MCAST_STATS_ENABLED "
+- enable
+.RI ( MCAST_STATS_ENABLED " > 0) "
+or disable
+.RI ( MCAST_STATS_ENABLED " == 0) "
+multicast (IGMP/MLD) stats accounting.
+
+.BI mcast_igmp_version " IGMP_VERSION "
+- set the IGMP version.
+
+.BI mcast_mld_version " MLD_VERSION "
+- set the MLD version.
+
+.BI nf_call_iptables " NF_CALL_IPTABLES "
+- enable
+.RI ( NF_CALL_IPTABLES " > 0) "
+or disable
+.RI ( NF_CALL_IPTABLES " == 0) "
+iptables hooks on the bridge.
+
+.BI nf_call_ip6tables " NF_CALL_IP6TABLES "
+- enable
+.RI ( NF_CALL_IP6TABLES " > 0) "
+or disable
+.RI ( NF_CALL_IP6TABLES " == 0) "
+ip6tables hooks on the bridge.
+
+.BI nf_call_arptables " NF_CALL_ARPTABLES "
+- enable
+.RI ( NF_CALL_ARPTABLES " > 0) "
+or disable
+.RI ( NF_CALL_ARPTABLES " == 0) "
+arptables hooks on the bridge.
+
+
+.in-8
+
+.TP
 MACsec Type Support
 For a link of type
 .I MACsec
-- 
2.12.1
