From: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
	components.
Date: Fri, 18 Nov 2011 21:30:03 -0800
Message-ID: <4EC73EDB.1010204@intel.com>
References: <1321657938-21761-1-git-send-email-jesse@nicira.com>
	<1321657938-21761-5-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1321657938-21761-5-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/18/2011 3:12 PM, Jesse Gross wrote:
> Open vSwitch is a multilayer Ethernet switch targeted at virtualized
> environments.  In addition to supporting a variety of features
> expected in a traditional hardware switch, it enables fine-grained
> programmatic extension and flow-based control of the network.
> This control is useful in a wide variety of applications but is
> particularly important in multi-server virtualization deployments,
> which are often characterized by highly dynamic endpoints and the need
> to maintain logical abstractions for multiple tenants.
> 
> The Open vSwitch datapath provides an in-kernel fast path for packet
> forwarding.  It is complemented by a userspace daemon, ovs-vswitchd,
> which is able to accept configuration from a variety of sources and
> translate it into packet processing rules.
> 
> See http://openvswitch.org for more information and userspace
> utilities.
> 
> Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> ---

Hi Jesse,

I scanned this code quickly and just made some quick notes on anything
I happened to see as I went through it.

Monday I'll take make an actual attempt at reviewing this.

[...]

> + */
> +enum ovs_frag_type {
> +       OVS_FRAG_TYPE_NONE,
> +       OVS_FRAG_TYPE_FIRST,
> +       OVS_FRAG_TYPE_LATER,
> +       __OVS_FRAG_TYPE_MAX
> +};
> +
> +#define OVS_FRAG_TYPE_MAX (__OVS_FRAG_TYPE_MAX - 1)
> +
> +struct ovs_key_ethernet {
> +       __u8     eth_src[6];
> +       __u8     eth_dst[6];
> +};
> +
> +struct ovs_key_ipv4 {
> +       __be32 ipv4_src;
> +       __be32 ipv4_dst;
> +       __u8   ipv4_proto;
> +       __u8   ipv4_tos;
> +       __u8   ipv4_ttl;
> +       __u8   ipv4_frag;       /* One of OVS_FRAG_TYPE_*. */
> +};
> +
> +struct ovs_key_ipv6 {
> +       __be32 ipv6_src[4];
> +       __be32 ipv6_dst[4];
> +       __be32 ipv6_label;      /* 20-bits in least-significant bits. */
> +       __u8   ipv6_proto;
> +       __u8   ipv6_tclass;
> +       __u8   ipv6_hlimit;
> +       __u8   ipv6_frag;       /* One of OVS_FRAG_TYPE_*. */
> +};
> +
> +struct ovs_key_tcp {
> +       __be16 tcp_src;
> +       __be16 tcp_dst;
> +};
> +
> +struct ovs_key_udp {
> +       __be16 udp_src;
> +       __be16 udp_dst;
> +};
> +
> +struct ovs_key_icmp {
> +       __u8 icmp_type;
> +       __u8 icmp_code;
> +};
> +
> +struct ovs_key_icmpv6 {
> +       __u8 icmpv6_type;
> +       __u8 icmpv6_code;
> +};
> +
> +struct ovs_key_arp {
> +       __be32 arp_sip;
> +       __be32 arp_tip;
> +       __be16 arp_op;
> +       __u8   arp_sha[6];
> +       __u8   arp_tha[6];
> +};
> +
> +struct ovs_key_nd {
> +       __u32 nd_target[4];
> +       __u8  nd_sll[6];
> +       __u8  nd_tll[6];
> +};
> +

We already have defines for many of these headers 

struct arphdr {
        __be16          ar_hrd;         /* format of hardware address   */
        __be16          ar_pro;         /* format of protocol address   */
        unsigned char   ar_hln;         /* length of hardware address   */
        unsigned char   ar_pln;         /* length of protocol address   */
        __be16          ar_op;          /* ARP opcode (command)         */

#if 0
         /*
          *      Ethernet looks like this : This bit is variable sized however...
          */
        unsigned char           ar_sha[ETH_ALEN];       /* sender hardware address      */
        unsigned char           ar_sip[4];              /* sender IP address            */
        unsigned char           ar_tha[ETH_ALEN];       /* target hardware address      */
        unsigned char           ar_tip[4];              /* target IP address            */
#endif

};

Do we have to redefine them here?

> --- /dev/null
> +++ b/net/openvswitch/actions.c
> @@ -0,0 +1,415 @@
> +/*
> + * Copyright (c) 2007-2011 Nicira Networks.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA
> + */
> +

It seems like most of the actions could be implemented with packet
actions ./net/sched or someplace else more generically.

[...]

> --- /dev/null
> +++ b/net/openvswitch/datapath.c
> @@ -0,0 +1,1888 @@
> +/*
> + * Copyright (c) 2007-2011 Nicira Networks.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA
> + */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_vlan.h>
> +#include <linux/in.h>
> +#include <linux/ip.h>
> +#include <linux/jhash.h>
> +#include <linux/delay.h>
> +#include <linux/time.h>
> +#include <linux/etherdevice.h>
> +#include <linux/genetlink.h>
> +#include <linux/kernel.h>
> +#include <linux/kthread.h>
> +#include <linux/mutex.h>
> +#include <linux/percpu.h>
> +#include <linux/rcupdate.h>
> +#include <linux/tcp.h>
> +#include <linux/udp.h>
> +#include <linux/version.h>
> +#include <linux/ethtool.h>
> +#include <linux/wait.h>
> +#include <asm/system.h>
> +#include <asm/div64.h>
> +#include <linux/highmem.h>
> +#include <linux/netfilter_bridge.h>
> +#include <linux/netfilter_ipv4.h>
> +#include <linux/inetdevice.h>
> +#include <linux/list.h>
> +#include <linux/openvswitch.h>
> +#include <linux/rculist.h>
> +#include <linux/dmi.h>
> +#include <net/genetlink.h>
> +
> +#include "datapath.h"
> +#include "flow.h"
> +#include "vport-internal_dev.h"
> +
> +/**
> + * DOC: Locking:
> + *
> + * Writes to device state (add/remove datapath, port, set operations on vports,
> + * etc.) are protected by RTNL.
> + *
> + * Writes to other state (flow table modifications, set miscellaneous datapath
> + * parameters, etc.) are protected by genl_mutex.  The RTNL lock nests inside
> + * genl_mutex.
> + *
> + * Reads are protected by RCU.
> + *
> + * There are a few special cases (mostly stats) that have their own
> + * synchronization but they nest under all of above and don't interact with
> + * each other.
> + */
> +
> +/* Global list of datapaths to enable dumping them all out.
> + * Protected by genl_mutex.
> + */
> +static LIST_HEAD(dps);
> +
> +static struct vport *new_vport(const struct vport_parms *);
> +static int queue_gso_packets(int dp_ifindex, struct sk_buff *,
> +                            const struct dp_upcall_info *);
> +static int queue_userspace_packet(int dp_ifindex, struct sk_buff *,
> +                                 const struct dp_upcall_info *);
> +
> +/* Must be called with rcu_read_lock, genl_mutex, or RTNL lock. */
> +static struct datapath *get_dp(int dp_ifindex)
> +{
> +       struct datapath *dp = NULL;
> +       struct net_device *dev;
> +
> +       rcu_read_lock();

comment seems incorrect in light of this rcu_read_lock()

> +       dev = dev_get_by_index_rcu(&init_net, dp_ifindex);
> +       if (dev) {
> +               struct vport *vport = internal_dev_get_vport(dev);
> +               if (vport)
> +                       dp = vport->dp;
> +       }
> +       rcu_read_unlock();
> +
> +       return dp;
> +}
> +
> +/* Must be called with genl_mutex. */
> +static struct flow_table *get_table_protected(struct datapath *dp)

I think, 'ovstable_dereference()' would be a better name. It matches existing
semantics of rtnl_dereference(). Bit of a nit though.

> +{
> +       return rcu_dereference_protected(dp->table, lockdep_genl_is_held());
> +}
> +
> +/* Must be called with rcu_read_lock or RTNL lock. */
> +static struct vport *get_vport_protected(struct datapath *dp, u16 port_no)
> +{

hmm but rcu_dereference_rtnl is not the same as rtnl_dereference_protected(). So
which one did you actually mean? The function name makes me thing you really wanted
the protected variant.

> +       return rcu_dereference_rtnl(dp->ports[port_no]);
> +}
> +
> +/* Must be called with rcu_read_lock or RTNL lock. */
> +const char *dp_name(const struct datapath *dp)
> +{
> +       struct vport *vport = rcu_dereference_rtnl(dp->ports[OVSP_LOCAL]);
> +       return vport->ops->get_name(vport);
> +}
> +

[...]

> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> new file mode 100644
> index 0000000..77c16c7
> --- /dev/null
> +++ b/net/openvswitch/flow.c
> @@ -0,0 +1,1373 @@
> +/*
> + * Copyright (c) 2007-2011 Nicira Networks.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA
> + */
> +
> +#include "flow.h"
> +#include "datapath.h"
> +#include <linux/uaccess.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/if_ether.h>
> +#include <linux/if_vlan.h>
> +#include <net/llc_pdu.h>
> +#include <linux/kernel.h>
> +#include <linux/jhash.h>
> +#include <linux/jiffies.h>
> +#include <linux/llc.h>
> +#include <linux/module.h>
> +#include <linux/in.h>
> +#include <linux/rcupdate.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_ether.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/tcp.h>
> +#include <linux/udp.h>
> +#include <linux/icmp.h>
> +#include <linux/icmpv6.h>
> +#include <linux/rculist.h>
> +#include <net/ip.h>
> +#include <net/ipv6.h>
> +#include <net/ndisc.h>
> +
> +static struct kmem_cache *flow_cache;
> +static unsigned int hash_seed __read_mostly;
> +
> +static int check_header(struct sk_buff *skb, int len)
> +{
> +       if (unlikely(skb->len < len))
> +               return -EINVAL;

I believe pskb_may_pull() checks skb->len so this is just a
return value change?

> +       if (unlikely(!pskb_may_pull(skb, len)))
> +               return -ENOMEM;
> +       return 0;
> +}
> +
> +static bool arphdr_ok(struct sk_buff *skb)
> +{
> +       return pskb_may_pull(skb, skb_network_offset(skb) +
> +                                 sizeof(struct arp_eth_header));
> +}
> +
> +static int check_iphdr(struct sk_buff *skb)
> +{
> +       unsigned int nh_ofs = skb_network_offset(skb);
> +       unsigned int ip_len;
> +       int err;
> +
> +       err = check_header(skb, nh_ofs + sizeof(struct iphdr));
> +       if (unlikely(err))
> +               return err;
> +
> +       ip_len = ip_hdrlen(skb);
> +       if (unlikely(ip_len < sizeof(struct iphdr) ||
> +                    skb->len < nh_ofs + ip_len))
> +               return -EINVAL;
> +
> +       skb_set_transport_header(skb, nh_ofs + ip_len);
> +       return 0;
> +}
> +
> +static bool tcphdr_ok(struct sk_buff *skb)
> +{
> +       int th_ofs = skb_transport_offset(skb);
> +       int tcp_len;
> +
> +       if (unlikely(!pskb_may_pull(skb, th_ofs + sizeof(struct tcphdr))))
> +               return false;
> +
> +       tcp_len = tcp_hdrlen(skb);
> +       if (unlikely(tcp_len < sizeof(struct tcphdr) ||
> +                    skb->len < th_ofs + tcp_len))
> +               return false;
> +
> +       return true;
> +}
> +
> +static bool udphdr_ok(struct sk_buff *skb)
> +{
> +       return pskb_may_pull(skb, skb_transport_offset(skb) +
> +                                 sizeof(struct udphdr));
> +}
> +
> +static bool icmphdr_ok(struct sk_buff *skb)
> +{
> +       return pskb_may_pull(skb, skb_transport_offset(skb) +
> +                                 sizeof(struct icmphdr));
> +}
> +

[...]

> --- /dev/null
> +++ b/net/openvswitch/vport-netdev.c
> @@ -0,0 +1,200 @@
> +/*
> + * Copyright (c) 2007-2011 Nicira Networks.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA
> + */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/if_arp.h>
> +#include <linux/if_bridge.h>
> +#include <linux/if_vlan.h>
> +#include <linux/kernel.h>
> +#include <linux/llc.h>
> +#include <linux/rtnetlink.h>
> +#include <linux/skbuff.h>
> +
> +#include <net/llc.h>
> +
> +#include "datapath.h"
> +#include "vport-internal_dev.h"
> +#include "vport-netdev.h"
> +
> +/* Must be called with rcu_read_lock. */
> +static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
> +{
> +       if (unlikely(!vport)) {
> +               kfree_skb(skb);
> +               return;
> +       }
> +
> +       /* Make our own copy of the packet.  Otherwise we will mangle the
> +        * packet for anyone who came before us (e.g. tcpdump via AF_PACKET).
> +        * (No one comes after us, since we tell handle_bridge() that we took
> +        * the packet.) */
> +       skb = skb_share_check(skb, GFP_ATOMIC);
> +       if (unlikely(!skb))
> +               return;
> +
> +       skb_push(skb, ETH_HLEN);
> +       vport_receive(vport, skb);
> +}
> +
> +/* Called with rcu_read_lock and bottom-halves disabled. */
> +static rx_handler_result_t netdev_frame_hook(struct sk_buff **pskb)
> +{
> +       struct sk_buff *skb = *pskb;
> +       struct vport *vport;
> +
> +       if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
> +               return RX_HANDLER_PASS;
> +
> +       vport = netdev_get_vport(skb->dev);
> +
> +       netdev_port_receive(vport, skb);
> +
> +       return RX_HANDLER_CONSUMED;
> +}
> +
> +static struct vport *netdev_create(const struct vport_parms *parms)
> +{
> +       struct vport *vport;
> +       struct netdev_vport *netdev_vport;
> +       int err;
> +
> +       vport = vport_alloc(sizeof(struct netdev_vport),
> +                           &netdev_vport_ops, parms);
> +       if (IS_ERR(vport)) {
> +               err = PTR_ERR(vport);
> +               goto error;
> +       }
> +
> +       netdev_vport = netdev_vport_priv(vport);
> +
> +       netdev_vport->dev = dev_get_by_name(&init_net, parms->name);
> +       if (!netdev_vport->dev) {
> +               err = -ENODEV;
> +               goto error_free_vport;
> +       }
> +
> +       if (netdev_vport->dev->flags & IFF_LOOPBACK ||
> +           netdev_vport->dev->type != ARPHRD_ETHER ||
> +           is_internal_dev(netdev_vport->dev)) {
> +               err = -EINVAL;
> +               goto error_put;
> +       }
> +
> +       err = netdev_rx_handler_register(netdev_vport->dev, netdev_frame_hook,
> +                                        vport);
> +       if (err)
> +               goto error_put;
> +
> +       dev_set_promiscuity(netdev_vport->dev, 1);
> +       netdev_vport->dev->priv_flags |= IFF_OVS_DATAPATH;
> +
> +       return vport;
> +
> +error_put:
> +       dev_put(netdev_vport->dev);
> +error_free_vport:
> +       vport_free(vport);
> +error:
> +       return ERR_PTR(err);
> +}
> +
> +static void netdev_destroy(struct vport *vport)
> +{
> +       struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
> +
> +       netdev_vport->dev->priv_flags &= ~IFF_OVS_DATAPATH;
> +       netdev_rx_handler_unregister(netdev_vport->dev);
> +       dev_set_promiscuity(netdev_vport->dev, -1);
> +
> +       synchronize_rcu();
> +
> +       dev_put(netdev_vport->dev);
> +       vport_free(vport);
> +}
> +
> +const char *netdev_get_name(const struct vport *vport)
> +{
> +       const struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
> +       return netdev_vport->dev->name;
> +}
> +
> +int netdev_get_ifindex(const struct vport *vport)
> +{
> +       const struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
> +       return netdev_vport->dev->ifindex;
> +}
> +
> +
> +static unsigned packet_length(const struct sk_buff *skb)
> +{
> +       unsigned length = skb->len - ETH_HLEN;
> +
> +       if (skb->protocol == htons(ETH_P_8021Q))
> +               length -= VLAN_HLEN;
> +
> +       return length;
> +}
> +
> +static int netdev_send(struct vport *vport, struct sk_buff *skb)
> +{
> +       struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
> +       int mtu = netdev_vport->dev->mtu;
> +       int len;
> +
> +       if (unlikely(packet_length(skb) > mtu && !skb_is_gso(skb))) {
> +               if (net_ratelimit())
> +                       pr_warn("%s: dropped over-mtu packet: %d > %d\n",
> +                               dp_name(vport->dp), packet_length(skb), mtu);
> +               goto error;
> +       }
> +
> +       if (unlikely(skb_warn_if_lro(skb)))
> +               goto error;
> +
> +       skb->dev = netdev_vport->dev;
> +       len = skb->len;
> +       dev_queue_xmit(skb);
> +
> +       return len;
> +
> +error:
> +       kfree_skb(skb);
> +       vport_record_error(vport, VPORT_E_TX_DROPPED);
> +       return 0;
> +}
> +
> +/* Returns null if this device is not attached to a datapath. */
> +struct vport *netdev_get_vport(struct net_device *dev)
> +{
> +       if (likely(dev->priv_flags & IFF_OVS_DATAPATH))
> +               return (struct vport *)
> +                       rcu_dereference_rtnl(dev->rx_handler_data);
> +       else
> +               return NULL;
> +}
> +
> +const struct vport_ops netdev_vport_ops = {
> +       .type           = OVS_VPORT_TYPE_NETDEV,
> +       .create         = netdev_create,
> +       .destroy        = netdev_destroy,
> +       .get_name       = netdev_get_name,
> +       .get_ifindex    = netdev_get_ifindex,
> +       .send           = netdev_send,
> +};
> +
> diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
> new file mode 100644
> index 0000000..6cc8719
> --- /dev/null
> +++ b/net/openvswitch/vport-netdev.h
> @@ -0,0 +1,42 @@
> +/*
> + * Copyright (c) 2007-2011 Nicira Networks.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA
> + */
> +
> +#ifndef VPORT_NETDEV_H
> +#define VPORT_NETDEV_H 1
> +
> +#include <linux/netdevice.h>
> +
> +#include "vport.h"
> +
> +struct vport *netdev_get_vport(struct net_device *dev);
> +
> +struct netdev_vport {
> +       struct net_device *dev;
> +};

This seems looks like a pretty worthless abstraction on the
surface at least.

> +
> +static inline struct netdev_vport *
> +netdev_vport_priv(const struct vport *vport)
> +{
> +       return vport_priv(vport);
> +}

Again it seems straight forward enough to just call vport_priv()

> +
> +const char *netdev_get_name(const struct vport *);
> +const char *netdev_get_config(const struct vport *);
> +int netdev_get_ifindex(const struct vport *);
> +


Thanks,
John
