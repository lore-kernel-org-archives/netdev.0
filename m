From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next 01/13] openvswitch: split flow
 structures into ovs specific and generic ones
Date: Thu, 4 Sep 2014 14:33:23 +0200
Message-ID: <20140904123323.GF1867@nanopsycho.lan>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <1409736300-12303-2-git-send-email-jiri@resnulli.us>
 <CALnjE+pscRmfhaWgkWCunJfjvG04RiNUAj6nefSFHrknQTC+xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Rony Efraim <ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
 Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALnjE+pscRmfhaWgkWCunJfjvG04RiNUAj6nefSFHrknQTC+xw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Wed, Sep 03, 2014 at 08:41:39PM CEST, pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org wrote:
>On Wed, Sep 3, 2014 at 2:24 AM, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org> wrote:
>> After this, flow related structures can be used in other code.
>>
>> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>> ---
>>  include/net/sw_flow.h          |  99 ++++++++++++++++++++++++++++++++++
>>  net/openvswitch/actions.c      |   3 +-
>>  net/openvswitch/datapath.c     |  74 +++++++++++++-------------
>>  net/openvswitch/datapath.h     |   4 +-
>>  net/openvswitch/flow.c         |   6 +--
>>  net/openvswitch/flow.h         | 102 +++++++----------------------------
>>  net/openvswitch/flow_netlink.c |  53 +++++++++---------
>>  net/openvswitch/flow_netlink.h |  10 ++--
>>  net/openvswitch/flow_table.c   | 118 ++++++++++++++++++++++-------------------
>>  net/openvswitch/flow_table.h   |  30 +++++------
>>  net/openvswitch/vport-gre.c    |   4 +-
>>  net/openvswitch/vport-vxlan.c  |   2 +-
>>  net/openvswitch/vport.c        |   2 +-
>>  net/openvswitch/vport.h        |   2 +-
>>  14 files changed, 276 insertions(+), 233 deletions(-)
>>  create mode 100644 include/net/sw_flow.h
>>
>> diff --git a/include/net/sw_flow.h b/include/net/sw_flow.h
>> new file mode 100644
>> index 0000000..21724f1
>> --- /dev/null
>> +++ b/include/net/sw_flow.h
>> @@ -0,0 +1,99 @@
>> +/*
>> + * include/net/sw_flow.h - Generic switch flow structures
>> + * Copyright (c) 2007-2012 Nicira, Inc.
>> + * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License as published by
>> + * the Free Software Foundation; either version 2 of the License, or
>> + * (at your option) any later version.
>> + */
>> +
>> +#ifndef _NET_SW_FLOW_H_
>> +#define _NET_SW_FLOW_H_
>> +
>> +struct sw_flow_key_ipv4_tunnel {
>> +       __be64 tun_id;
>> +       __be32 ipv4_src;
>> +       __be32 ipv4_dst;
>> +       __be16 tun_flags;
>> +       u8   ipv4_tos;
>> +       u8   ipv4_ttl;
>> +};
>> +
>> +struct sw_flow_key {
>> +       struct sw_flow_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel key. */
>> +       struct {
>> +               u32     priority;       /* Packet QoS priority. */
>> +               u32     skb_mark;       /* SKB mark. */
>> +               u16     in_port;        /* Input switch port (or DP_MAX_PORTS). */
>> +       } __packed phy; /* Safe when right after 'tun_key'. */
>> +       struct {
>> +               u8     src[ETH_ALEN];   /* Ethernet source address. */
>> +               u8     dst[ETH_ALEN];   /* Ethernet destination address. */
>> +               __be16 tci;             /* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
>> +               __be16 type;            /* Ethernet frame type. */
>> +       } eth;
>> +       struct {
>> +               u8     proto;           /* IP protocol or lower 8 bits of ARP opcode. */
>> +               u8     tos;             /* IP ToS. */
>> +               u8     ttl;             /* IP TTL/hop limit. */
>> +               u8     frag;            /* One of OVS_FRAG_TYPE_*. */
>> +       } ip;
>> +       struct {
>> +               __be16 src;             /* TCP/UDP/SCTP source port. */
>> +               __be16 dst;             /* TCP/UDP/SCTP destination port. */
>> +               __be16 flags;           /* TCP flags. */
>> +       } tp;
>> +       union {
>> +               struct {
>> +                       struct {
>> +                               __be32 src;     /* IP source address. */
>> +                               __be32 dst;     /* IP destination address. */
>> +                       } addr;
>> +                       struct {
>> +                               u8 sha[ETH_ALEN];       /* ARP source hardware address. */
>> +                               u8 tha[ETH_ALEN];       /* ARP target hardware address. */
>> +                       } arp;
>> +               } ipv4;
>> +               struct {
>> +                       struct {
>> +                               struct in6_addr src;    /* IPv6 source address. */
>> +                               struct in6_addr dst;    /* IPv6 destination address. */
>> +                       } addr;
>> +                       __be32 label;                   /* IPv6 flow label. */
>> +                       struct {
>> +                               struct in6_addr target; /* ND target address. */
>> +                               u8 sll[ETH_ALEN];       /* ND source link layer address. */
>> +                               u8 tll[ETH_ALEN];       /* ND target link layer address. */
>> +                       } nd;
>> +               } ipv6;
>> +       };
>> +} __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
>> +
>
>HW offload API should be separate from OVS module. This has following
>advantages.
>1. It can be managed by OVS userspace vswitchd process which has much
>better context to setup hardware flow table. Once we add capabilities
>for swdev, it is much more easier for vswitchd process to choose
>correct (hw or sw) flow table for given flow.

The idea is to add a nl attr in ovs genl iface so the vswitchd can
speficify the flow the to be in sw only, in hw only, in both.
I believe that is is more convenient to let switchd to communicate flows
via single iface.

>2. Other application that wants to use HW offload does not have
>dependency on OVS kernel module.

That is not the case for this patchset. Userspace can insert/remove
flows using the switchdev generic netlink api - see:
[patch net-next 13/13] switchdev: introduce Netlink API

>3. Hardware and software datapath remains separate, these two
>components has no dependency on each other, both can be developed
>independent of each other.


The general idea is to have the offloads handled in-kernel. Therefore I
hooked on to ovs kernel dp code.
