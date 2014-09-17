From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/13] openvswitch: split flow structures into
 ovs specific and generic ones
Date: Wed, 17 Sep 2014 10:34:21 +0200
Message-ID: <20140917083421.GB1863@nanopsycho.orion>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <1409736300-12303-2-git-send-email-jiri@resnulli.us>
 <CALnjE+pscRmfhaWgkWCunJfjvG04RiNUAj6nefSFHrknQTC+xw@mail.gmail.com>
 <20140904123323.GF1867@nanopsycho.lan>
 <CALnjE+qwbQ=5wsLddvZX95xE2_U=osuDg8S10zKWarMD9mp4Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	nhorman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"jeffrey.t.kirsher" <jeffrey.t.kirsher@intel.com>,
	vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"john.r.fastabend" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	sfeldma <sfeldma@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	jasowang <jasowang@redhat.com>, ebiederm
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:60342 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbaIQIeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 04:34:24 -0400
Received: by mail-we0-f173.google.com with SMTP id u56so1029627wes.32
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 01:34:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALnjE+qwbQ=5wsLddvZX95xE2_U=osuDg8S10zKWarMD9mp4Aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 04, 2014 at 10:46:28PM CEST, pshelar@nicira.com wrote:
>On Thu, Sep 4, 2014 at 5:33 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Sep 03, 2014 at 08:41:39PM CEST, pshelar@nicira.com wrote:
>>>On Wed, Sep 3, 2014 at 2:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> After this, flow related structures can be used in other code.
>>>>
>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>> ---
>>>>  include/net/sw_flow.h          |  99 ++++++++++++++++++++++++++++++++++
>>>>  net/openvswitch/actions.c      |   3 +-
>>>>  net/openvswitch/datapath.c     |  74 +++++++++++++-------------
>>>>  net/openvswitch/datapath.h     |   4 +-
>>>>  net/openvswitch/flow.c         |   6 +--
>>>>  net/openvswitch/flow.h         | 102 +++++++----------------------------
>>>>  net/openvswitch/flow_netlink.c |  53 +++++++++---------
>>>>  net/openvswitch/flow_netlink.h |  10 ++--
>>>>  net/openvswitch/flow_table.c   | 118 ++++++++++++++++++++++-------------------
>>>>  net/openvswitch/flow_table.h   |  30 +++++------
>>>>  net/openvswitch/vport-gre.c    |   4 +-
>>>>  net/openvswitch/vport-vxlan.c  |   2 +-
>>>>  net/openvswitch/vport.c        |   2 +-
>>>>  net/openvswitch/vport.h        |   2 +-
>>>>  14 files changed, 276 insertions(+), 233 deletions(-)
>>>>  create mode 100644 include/net/sw_flow.h
>>>>
>>>> diff --git a/include/net/sw_flow.h b/include/net/sw_flow.h
>>>> new file mode 100644
>>>> index 0000000..21724f1
>>>> --- /dev/null
>>>> +++ b/include/net/sw_flow.h
>>>> @@ -0,0 +1,99 @@
>>>> +/*
>>>> + * include/net/sw_flow.h - Generic switch flow structures
>>>> + * Copyright (c) 2007-2012 Nicira, Inc.
>>>> + * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
>>>> + *
>>>> + * This program is free software; you can redistribute it and/or modify
>>>> + * it under the terms of the GNU General Public License as published by
>>>> + * the Free Software Foundation; either version 2 of the License, or
>>>> + * (at your option) any later version.
>>>> + */
>>>> +
>>>> +#ifndef _NET_SW_FLOW_H_
>>>> +#define _NET_SW_FLOW_H_
>>>> +
>>>> +struct sw_flow_key_ipv4_tunnel {
>>>> +       __be64 tun_id;
>>>> +       __be32 ipv4_src;
>>>> +       __be32 ipv4_dst;
>>>> +       __be16 tun_flags;
>>>> +       u8   ipv4_tos;
>>>> +       u8   ipv4_ttl;
>>>> +};
>>>> +
>>>> +struct sw_flow_key {
>>>> +       struct sw_flow_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel key. */
>>>> +       struct {
>>>> +               u32     priority;       /* Packet QoS priority. */
>>>> +               u32     skb_mark;       /* SKB mark. */
>>>> +               u16     in_port;        /* Input switch port (or DP_MAX_PORTS). */
>>>> +       } __packed phy; /* Safe when right after 'tun_key'. */
>>>> +       struct {
>>>> +               u8     src[ETH_ALEN];   /* Ethernet source address. */
>>>> +               u8     dst[ETH_ALEN];   /* Ethernet destination address. */
>>>> +               __be16 tci;             /* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
>>>> +               __be16 type;            /* Ethernet frame type. */
>>>> +       } eth;
>>>> +       struct {
>>>> +               u8     proto;           /* IP protocol or lower 8 bits of ARP opcode. */
>>>> +               u8     tos;             /* IP ToS. */
>>>> +               u8     ttl;             /* IP TTL/hop limit. */
>>>> +               u8     frag;            /* One of OVS_FRAG_TYPE_*. */
>>>> +       } ip;
>>>> +       struct {
>>>> +               __be16 src;             /* TCP/UDP/SCTP source port. */
>>>> +               __be16 dst;             /* TCP/UDP/SCTP destination port. */
>>>> +               __be16 flags;           /* TCP flags. */
>>>> +       } tp;
>>>> +       union {
>>>> +               struct {
>>>> +                       struct {
>>>> +                               __be32 src;     /* IP source address. */
>>>> +                               __be32 dst;     /* IP destination address. */
>>>> +                       } addr;
>>>> +                       struct {
>>>> +                               u8 sha[ETH_ALEN];       /* ARP source hardware address. */
>>>> +                               u8 tha[ETH_ALEN];       /* ARP target hardware address. */
>>>> +                       } arp;
>>>> +               } ipv4;
>>>> +               struct {
>>>> +                       struct {
>>>> +                               struct in6_addr src;    /* IPv6 source address. */
>>>> +                               struct in6_addr dst;    /* IPv6 destination address. */
>>>> +                       } addr;
>>>> +                       __be32 label;                   /* IPv6 flow label. */
>>>> +                       struct {
>>>> +                               struct in6_addr target; /* ND target address. */
>>>> +                               u8 sll[ETH_ALEN];       /* ND source link layer address. */
>>>> +                               u8 tll[ETH_ALEN];       /* ND target link layer address. */
>>>> +                       } nd;
>>>> +               } ipv6;
>>>> +       };
>>>> +} __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
>>>> +
>>>
>>>HW offload API should be separate from OVS module. This has following
>>>advantages.
>>>1. It can be managed by OVS userspace vswitchd process which has much
>>>better context to setup hardware flow table. Once we add capabilities
>>>for swdev, it is much more easier for vswitchd process to choose
>>>correct (hw or sw) flow table for given flow.
>>
>> The idea is to add a nl attr in ovs genl iface so the vswitchd can
>> speficify the flow the to be in sw only, in hw only, in both.
>> I believe that is is more convenient to let switchd to communicate flows
>> via single iface.
>>
>How is it convenient? this patch complicates OVS kernel module. It add
>OVS interfaces for HW offload. And you need similar interfaces for
>switchdev device. So it duplicate code.

There is almost no code duplication there. And in next patchset
iteration I plan to have even less.


>On the other hand if vswitchd uses common interface (switchdev) there
>is no need to extend ovs kernel interface. For example specifying
>extra metadata, like (sw only, hw olny, both).

I understand you point of view. However from the offloading perspective
it makes much more sense to push the flows through a single interface
(ovs genl) and only offload selected flows to hw (pushing further).
Having vswitchd to handle 2 different ifaces for the same/similar thing
does not seem like a clean solution to me. And it really breaks the
offloading view.

Plus the amount of code needed to be pushed into ovs kernel dp code in
order to enable this is small.


>
>>>2. Other application that wants to use HW offload does not have
>>>dependency on OVS kernel module.
>>
>> That is not the case for this patchset. Userspace can insert/remove
>> flows using the switchdev generic netlink api - see:
>> [patch net-next 13/13] switchdev: introduce Netlink API
>>
>>>3. Hardware and software datapath remains separate, these two
>>>components has no dependency on each other, both can be developed
>>>independent of each other.
>>
>>
>> The general idea is to have the offloads handled in-kernel. Therefore I
>> hooked on to ovs kernel dp code.
>>
>>
>>
