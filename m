From: "D. Hugh Redelmeier" <hugh@mimosa.com>
Subject: Re: PATCH: netdev: add a cast NLMSG_OK to avoid a GCC warning in
 users' code
Date: Fri, 11 Sep 2015 02:21:28 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1509110204200.4754@redclaw.mimosa.com>
References: <alpine.LRH.2.02.1509080933340.4754@redclaw.mimosa.com> <20150909.123717.2263645868892698375.davem@davemloft.net>
Reply-To: "D. Hugh Redelmeier" <hugh@mimosa.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-d.mimosa.com ([209.161.207.149]:45572 "EHLO gw-d.mimosa.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbbIKGVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2015 02:21:42 -0400
In-Reply-To: <20150909.123717.2263645868892698375.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Miller <davem@davemloft.net>

| Everyone either uses an unsigned type (such as "size_t") or adds an
| explicit cast to an unsinged type for the second argument.

That sounded odd to me.  So I looked through the Fedora code base, as
indexed by searchcode.com.  This took a stupid amount of time so I
didn't check my work.

Summary: 37 files use a signed type, 32 files use an unsigned type
(some are in each category!).

So your point is not correct.

It is amazing how many private definitions there are for NLMSG_OK.
They are mostly just copies but at least some leave out the int cast of
the result of sizeof.

The kernel's own version seems to be an inline function (with a
lower-case name).  It would be nice to replace the NLMSG_OK macro with
an inline function: this supports better type checking.  I don't know
if there are technical reasons not to do this.

Supporting data:

strongswan /strongswan-5.0.0/src/libhydra/plugins/kernel_netlink/kernel_netlink_ipsec.c
	int, size_t, size_t, size_t, size_t, size_t

libnfnetlink /libnfnetlink-1.0.0/src/libnfnetlink.c
	size_t, size_t, size_t, unsigned int

glibc /glibc-2.16-75f0d304/sysdeps/unix/sysv/linux/ifaddrs.c
arm-gp2x-linux-glibc /arm-gp2x-linux-glibc-2.3.6/glibc-2.3.6/sysdeps/unix/sysv/linux/ifaddrs.c
	size_t, size_t, size_t

strongswan /strongswan-5.0.0/src/libhydra/plugins/kernel_netlink/kernel_netlink_net.c
	int, size_t, size_t, size_t

fcoe-utils /fcoe-utils-1.0.23/fcoemon.c
	int, int, int

uClibc /uClibc-0.9.32/libc/inet/ifaddrs.c
	size_t, size_t, size_t

glibc /glibc-2.16-75f0d304/sysdeps/unix/sysv/linux/if_index.c
arm-gp2x-linux-glibc /arm-gp2x-linux-glibc-2.3.6/glibc-2.3.6/sysdeps/unix/sysv/linux/if_index.c
	size_t, size_t

bootchart /bootchart2-0.14.0/collector/tasks-netlink.c
	size_, size_t

netlabel_tools /netlabel_tools-0.19/libnetlabel/mod_mgmt.c
netlabel_tools /netlabel_tools-0.19/libnetlabel/mod_unlabeled.c
	each has int, int

bird /bird-1.3.7/sysdep/linux/netlink/netlink.c
	unsigned int, unsigned int

gtk-gnutella /gtk-gnutella-0.97.1/src/lib/getgateway.c
	unsigned, unsigned

iproute /iproute2-3.4.0/lib/libnetlink.c
	int, int

iproute /iproute2-3.4.0/misc/ss.c
	int, ssize_t

lldpad /lldpad-0.9.44/lldp_dcbx_nl.c
	unsigned

dlm /dlm-3.99.5/dlm_controld/netlink.c
	int, int

gnet2 /gnet-2.0.8/src/usagi_ifaddrs.c
	int, int

dnsmasq /dnsmasq-2.59/src/netlink.c
	size_t (through cast of ssize_t value), size_t (through cast of ssize_t value)

net-snmp /net-snmp-5.7.1/agent/mibgroup/ip-mib/data_access/ipaddress_linux.c
	int, int

net-snmp /net-snmp-5.7.1/agent/mibgroup/ip-mib/data_access/defaultrouter_linux.c
	int

rb_libtorrent /libtorrent-rasterbar-0.16.2/src/enum_net.cpp
	int, int

bootparamd /netkit-bootparamd-0.17/rpc.bootparamd/bootparam_default_route.c
	u_int (through cast of int value), u_int (through cast of int value)

nss-myhostname /nss-myhostname-0.3/netlink.c
	size_t (through cast of ssize_t value)

glibc /glibc-2.16-75f0d304/sysdeps/unix/sysv/linux/check_native.c
glibc /glibc-2.16-75f0d304/sysdeps/unix/sysv/linux/check_pf.c
	size_t (through cast of ssize_t value)

audit /audit-2.2.1/lib/netlink.c
	unsigned int (through cast of int)

rstp /rstp/libnetlink.c
	int

fence-virt /fence-virt-0.3.0/common/ip_lookup.c
	int

libpcap /libpcap-1.3.0/pcap-netfilter-linux.c
	int

oidentd /oidentd-2.0.8/src/kernel/linux.c
	has it's own copy of the definition of NLMSG_OK, without cast to int
	size_t (cast of ssize_t value)

netlabel_tools /netlabel_tools-0.19/libnetlabel/netlabel_comm.c
	int

netlabel_tools /netlabel_tools-0.19/libnetlabel/mod_cipsov4.c
	int

keepalived /keepalived-1.2.2/keepalived/vrrp/vrrp_netlink.c
	int

xen /xen-4.1.2/tools/python/xen/lowlevel/netlink/libnetlink.c
	int

mipv6-daemon /mipv6-daemon-2.0.2.20110203bgit/libnetlink/libnetlink.c
	size_t (cast of int value)

avahi /avahi-0.6.31/avahi-core/netlink.c
	size_t (cast of ssize_t)

avahi /avahi-0.6.31/avahi-autoipd/iface-linux.c
	size_t

libcgroup /libcgroup-0.38/src/daemon/cgrulesengd.c
	size_t (but code would probably be more correct with ssize_t)

libnl /libnl-1.1/lib/nl.c
	int

pl /pl-6.0.2/packages/tipc/tipcutils/tipc-config.c
	int

mingw-glib2 /glib-2.33.1/gio/gnetworkmonitornetlink.c
	size_t (cast of gssize value)

fcoe-utils /fcoe-utils-1.0.23/lib/rtnetlink.c
	int

libnl3 /libnl-3.2.7/lib/nl.c
	int

iscsi-initiator-utils /open-iscsi-2.0-872-rc4-bnx2i/usr/dcb_app.c
	unsigned int (cast from int)

lldpad /lldpad-0.9.44/lldp_rtnl.c
	unsigned

lldpad /lldpad-0.9.44/nltest.c
	unsigned int (cast from int)

ebtables /ebtables-v2.0.10-4/examples/ulog/test_ulog.c
	65536 (odd! bug?); counts as an int

wpa_supplicant /wpa_supplicant-1.0-rc3/src/drivers/netlink.c
	int

ipsec-tools /ipsec-tools-0.8.0/src/racoon/grabmyaddr.c
	int

ulogd /ulogd-2.0.0beta4/libipulog/libipulog.c
	size_t

gupnp /gupnp-0.18.3/libgupnp/gupnp-linux-context-manager.c
	int

ike /ike/source/libip/libip.route.cpp
	int

libnfnetlink /libnfnetlink-1.0.0/src/rtnl.c
	int

dnsmasq /dnsmasq-2.59/contrib/wrt/dhcp_release.c
	size_t (cast from ssize_t)

netplug /netplug-1.2.9.1/netlink.c
	int

oidentd /oidentd-2.0.8/src/kernel/linux.c
	size_t (from ssize_t)

certmonger /certmonger-0.59/src/netlink.c
	size_t (cast from int)

certmonger /certmonger-0.59/src/nl-check.c
	unsigned int (cast from int)

radvd /radvd-1.9.1/netlink.c
	int

ptlib /ptlib-2.10.2/src/ptlib/unix/socket.cxx
	unsigned (cast from int)

acpid /acpid-2.0.16/kacpimon/libnetlink.c
	unsigned (cast from int)

net-snmp /net-snmp-5.7.1/agent/mibgroup/etherlike-mib/data_access/dot3stats_linux.c
	int

net-snmp /net-snmp-5.7.1/agent/mibgroup/if-mib/data_access/interface_linux.c
	int

net-snmp /net-snmp-5.7.1/agent/mibgroup/ip-mib/data_access/arp_netlink.c
	int

net-snmp /net-snmp-5.7.1/agent/mibgroup/mibII/tcpTable.c
	int

fprobe-ulog /fprobe-ulog-1.1/src/libipulog/libipulog.c
	size_t

busybox /busybox-1.19.4/networking/ifplugd.c
	ssize_t

busybox /busybox-1.19.4/networking/libiproute/libnetlink.c
	int

ntp /ntp-4.2.6p5/ntpd/ntp_io.c
	int
