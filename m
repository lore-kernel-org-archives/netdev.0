From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next RFC v2 0/6] introduce infrastructure
 for support of switch chip datapath
Date: Thu, 27 Mar 2014 08:23:00 +0100
Message-ID: <20140327072300.GD2845@minipsycho.orion>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <53334A3F.6020105@mojatatu.com>
 <CAGVrzcaOph7=2WfMzTfqtwFkN1fu5uKJAH59aF7mqD4MwL7iOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
 John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, vyasevic <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 Scott Feldman <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, dborkman <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGVrzcaOph7=2WfMzTfqtwFkN1fu5uKJAH59aF7mqD4MwL7iOg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

Wed, Mar 26, 2014 at 10:57:09PM CET, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>2014-03-26 14:44 GMT-07:00 Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>:
>> Jiri,
>>
>> The flow extensions may be distracting - note there are many
>> tables (L3, L2, etc) in such chips not just ACLs. And there's likely no
>> OneWay(tm) to add a flow. My view is probably to solve or reach an
>> agreement on the ports. Then resolve the different tables control/data
>> exposure.
>
>Agreed.
>
>> On the switchdev - You are still exposing it; do you expect these
>> things to be created from user space? Probably thats one approach, but
>> I would suspect the majority would result in the driver itself creating
>> these devices after discovering the resources from the control
>> interfaces (PCIE etc).
>
>It seems to me like, minus the strong MDIO dependency, DSA is probably
>the closest and most ready piece of software we have in the kernel to
>start building Ethernet switch port net_device as it already contains
>pretty much everything we want:
>
>- per-port ethtool operations
>- per-port xmit/rcv handlers
>- existing drivers
>
>The missing bits are roughly:
>
>- adding IFF_SWITCH_PORT flags to the slave net_device created
>- creating the switch master net_device: sw1
>- creating the Switch CPU port net_device: sw1p<N>

Yep. DSA should be fairly easy to modify to use switchdev api.

>
>>
>> cheers,
>> jamal
>>
>>
>>
>> On 03/26/14 12:31, Jiri Pirko wrote:
>>>
>>> This is second version of RFC. Here are the main differences from the
>>> first one:
>>> -There is no special swdev of swport structure. The switch and its ports
>>> are
>>>   now represented only by net_device structures. There are couple of
>>> switch-specific
>>>   ndos added (inserting and removing flows).
>>>
>>> -Regarding the flows, driver marks skb with "missing flow" flag now. That
>>> would
>>>   give indication to a user (OVS datapath of af_packet userspace
>>> application).
>>>   On the opposite direction, skb can be xmitted by a port.
>>>
>>> -dummyswitch module has now rtnetlink iface for easy creation of dummy
>>> switches
>>>   and ports.
>>>
>>> The basic idea is to introduce a generic infractructure to support various
>>> switch chips in kernel. Also the idea is to benefit of currently existing
>>> Open vSwitch userspace infrastructure.
>>>
>>>
>>> The first two patches are just minor skb flag and packet_type
>>> modifications.
>>>
>>>
>>> The third patch does a split of structures which are not specific to OVS
>>> into more generic ones that can be reused.
>>>
>>>
>>> The fourth patch introduces the "switchdev" API itself. It should serve as
>>> a glue between chip drivers on the one side and the user on the other.
>>> That user might be OVS datapath but in future it might be just userspace
>>> application interacting via af_packet and Netlink iface.
>>>
>>> The infrastructure is designed to be similar to for example linux bridge.
>>> There is one netdevice representing a switch chip and one netdevice per
>>> every
>>> port. These are bound together in classic slave-master way. The reason
>>> to reuse the netdevices for port representation is that userspace can use
>>> standard tools to get information about the ports, statistics, tcpdump,
>>> etc.
>>>
>>> Note that the netdevices are just representations of the ports in the
>>> switch.
>>> Therefore **no actual data** goes though, only missed flow skbs and, if
>>> drivers
>>> supports it, when ETH_P_ALL packet_type is hooked on (tcpdump).
>>>
>>>
>>> The fifth patch introduces a support for switchdev vports into OVS
>>> datapath.
>>> After that, userspace would be able to create a switchdev DP for a switch
>>> chip,
>>> to add switchdev ports to it and to use it in the same way as it would be
>>> OVS SW datapath.
>>>
>>>
>>> The sixth patch adds a dummy switch module. It is just an example of
>>> switchdev driver implementation.
>>>
>>>
>>> Jiri Pirko (6):
>>>    net: make packet_type->ak_packet_priv generic
>>>    skbuff: add "missed_flow" flag
>>>    openvswitch: split flow structures into ovs specific and generic ones
>>>    net: introduce switchdev API
>>>    openvswitch: Introduce support for switchdev based datapath
>>>    net: introduce dummy switch
>>>
>>>   drivers/net/Kconfig                        |   7 +
>>>   drivers/net/Makefile                       |   1 +
>>>   drivers/net/dummyswitch.c                  | 235
>>> +++++++++++++++++++++++++++++
>>>   include/linux/filter.h                     |   1 +
>>>   include/linux/netdevice.h                  |  26 +++-
>>>   include/linux/skbuff.h                     |  13 ++
>>>   include/linux/sw_flow.h                    | 105 +++++++++++++
>>>   include/linux/switchdev.h                  |  30 ++++
>>>   include/uapi/linux/if_link.h               |   9 ++
>>>   include/uapi/linux/openvswitch.h           |   4 +
>>>   net/Kconfig                                |  10 ++
>>>   net/core/Makefile                          |   1 +
>>>   net/core/dev.c                             |   4 +-
>>>   net/core/filter.c                          |   3 +
>>>   net/core/switchdev.c                       | 172 +++++++++++++++++++++
>>>   net/openvswitch/Makefile                   |   4 +
>>>   net/openvswitch/datapath.c                 |  90 +++++++----
>>>   net/openvswitch/datapath.h                 |  12 +-
>>>   net/openvswitch/dp_notify.c                |   3 +-
>>>   net/openvswitch/flow.c                     |  14 +-
>>>   net/openvswitch/flow.h                     | 123 +++------------
>>>   net/openvswitch/flow_netlink.c             |  24 +--
>>>   net/openvswitch/flow_netlink.h             |   4 +-
>>>   net/openvswitch/flow_table.c               | 100 ++++++------
>>>   net/openvswitch/flow_table.h               |  18 +--
>>>   net/openvswitch/vport-gre.c                |   4 +-
>>>   net/openvswitch/vport-internal_switchdev.c | 179 ++++++++++++++++++++++
>>>   net/openvswitch/vport-internal_switchdev.h |  28 ++++
>>>   net/openvswitch/vport-netdev.c             |   4 +-
>>>   net/openvswitch/vport-switchportdev.c      | 205
>>> +++++++++++++++++++++++++
>>>   net/openvswitch/vport-switchportdev.h      |  24 +++
>>>   net/openvswitch/vport-vxlan.c              |   2 +-
>>>   net/openvswitch/vport.c                    |   6 +-
>>>   net/openvswitch/vport.h                    |   4 +-
>>>   net/packet/af_packet.c                     |  22 ++-
>>>   35 files changed, 1269 insertions(+), 222 deletions(-)
>>>   create mode 100644 drivers/net/dummyswitch.c
>>>   create mode 100644 include/linux/sw_flow.h
>>>   create mode 100644 include/linux/switchdev.h
>>>   create mode 100644 net/core/switchdev.c
>>>   create mode 100644 net/openvswitch/vport-internal_switchdev.c
>>>   create mode 100644 net/openvswitch/vport-internal_switchdev.h
>>>   create mode 100644 net/openvswitch/vport-switchportdev.c
>>>   create mode 100644 net/openvswitch/vport-switchportdev.h
>>>
>>
>
>
>
>-- 
>Florian
