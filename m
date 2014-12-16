From: B Viswanath <marichika4@gmail.com>
Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
 bridge port attributes
Date: Wed, 17 Dec 2014 03:21:53 +0530
Message-ID: <CAN+pFwJgbbgYjU3-P=3h7G1v8Sz=naDAU880-6LJ3LTTciz7nA@mail.gmail.com>
References: <1418202320-19491-3-git-send-email-roopa@cumulusnetworks.com>
	<20141210093755.GB1863@nanopsycho.orion>
	<5489CBBA.7050302@cumulusnetworks.com>
	<20141211171145.GG1912@nanopsycho.orion>
	<5489DB73.1080808@cumulusnetworks.com>
	<20141211180743.GA2010@nanopsycho.orion>
	<5489E214.4080708@cumulusnetworks.com>
	<20141211222559.GB1880@nanopsycho.orion>
	<548D9B14.9010201@cumulusnetworks.com>
	<20141214153549.GA2174@nanopsycho.orion>
	<548DE7E2.6010705@cumulusnetworks.com>
	<548EFD94.8070905@mojatatu.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505D999EA@ORSMSX106.amr.corp.intel.com>
	<548F20FF.9080508@gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505D9FA8C@ORSMSX106.amr.corp.intel.com>
	<548F6E62.1040500@mojatatu.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505DA6149@ORSMSX101.amr.corp.intel.com>
	<548F88E8.1010703@cumulusnetworks.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505DB15CA@ORSMSX101.amr.corp.intel.com>
	<549060CF.5020706@gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505DB473D@ORSMSX101.amr.corp.intel.com>
	<CAN+pFwJuOBb2c49TUqX357DQLY9a7GUs7Kufne0Td=jSJ+nFeA@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505DB588F@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>, "tgraf@suug.ch" <tgraf@suug.ch>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:49417 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbaLPVvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 16:51:54 -0500
Received: by mail-qa0-f45.google.com with SMTP id i13so2594411qae.32
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 13:51:53 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505DB588F@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 December 2014 at 02:22, Arad, Ronen <ronen.arad@intel.com> wrote:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of B Viswanath
>> Sent: Tuesday, December 16, 2014 9:24 PM
>> To: Arad, Ronen
>> Cc: John Fastabend; netdev@vger.kernel.org; Roopa Prabhu; Jamal Hadi
>> Salim; Jiri Pirko; sfeldma@gmail.com; bcrl@kvack.org; tgraf@suug.ch;
>> stephen@networkplumber.org; linville@tuxdriver.com;
>> vyasevic@redhat.com; davem@davemloft.net;
>> shm@cumulusnetworks.com; gospo@cumulusnetworks.com
>> Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
>> bridge port attributes
>>
>> Hi,
>>
>> This is my first email on this thread, and on this list. My apologies if I have
>> not understood something correctly. I would like to participate  in this
>> discussion, which is one of the reasons I joined this list recently.  Some
>> feedback inline below.
>>
>> On 16 December 2014 at 22:59, Arad, Ronen <ronen.arad@intel.com> wrote:
>> >
>> >
> <sniped for brevity>
>> >>
>> >> I'm still missing why there is duplicate implementations in the driver.
>> >> If the driver implements the set of ndo ops why should it care who
>> >> calls them? I think you tried to explain this already but I'm not seeing it.
>> >>
>> >
>> > Let's consider a bridge property. I'll use the default PVID attribute as an
>> example. This is currently configurable by sysfs only and a netlink support for
>> that is still due. Let's assume for our discussion that a DEAFAULT_PVID
>> attribute will be added as a bridge attribute within AFSPEC nested attribute
>> of AF_BRIDGE SETLINK message.
>> > When a bridge device is present, this attribute is processed by the bridge
>> module and saved as default_pvid field in net_bridge structure. When a
>> switch port is enslaved to a bridge, the bridge driver creates a
>> net_bridge_port instance and assigns it a pvid inherited from the
>> default_pvid attribute of the bridge. Setting the pvid for a new enslaved
>> switch port is not done via netlink. It only applies to the net_bridge_port
>> structure which is internal to the bridge module. Offloading this to HW is not
>> addressed with current bridge offloading.
>> >
>> > When a bridge device is not used, the DEFAULT_PVID will be targeted using
>> the SELF flag to any of the switch ports. The driver will recognize that as a
>> bridge port and will need to maintain some switch global structure similar to
>> net_bridge where it could save the default_pvid. The driver, knowing that the
>> switch port is not enslaved to a bridge, will have to replicate the same
>> functionality. In the HW case, it will have to configure default VLAN on all the
>> switch ports.
>> > This is different from the yet to be defined way of propagating default PVID
>> from a bridge device to offloaded bridge ports.
>> >
>> > Another example is STP. STP attributes are bridge attributes which are not
>> offloaded when a bridge device is present. The bridge module handles STP
>> protocol internally. Without bridge device, STP attributes have to be targeted
>> at a switch port device and the driver should save them in driver-specific
>> structures and have proprietary implementation of STP (as the one in the
>> bridge module is not used).
>>
>> In general I feel that the switch-device and port relation should be that of the
>> 'container-containee'. This is the actual physical relationship.  Apart from
>> some operations such as vlans and protocol related, it is tricky to model all
>> operations directly on ports. My thinking is it is cleaner to have all operations
>> be on switch-device, which in turn peculates the operations downward, to its
>> contained ports as applicable.  The offloading is really a property of the
>> switch device and not individual ports. Similarly the FDB is maintained by the
>> switch and not the ports. As we extend the current offloading mechanism to
>> other L2, L3 and other features, we may find it easier to have a 'switch-
>> device' in place.
>>
>> I am somewhat confused with the notion of bridges though. Many existing
>> linux-based routers use bridges differently than as a vlan-broadcast-domain.
>> For example it is common to have eth0.334 and
>> eth1 in the same bridge. What is being done internally is that the additional
>> vlan tag 334 (which indicates video traffic, say) is removed and that video
>> traffic is being bridged to eth1. There is no default vlan for this bridge.  This is
>> a software bridge. I am not sure how this can be accomplished if there is a
>> need to associate a vlan with a bridge.
>>
>> Thanks
>> Viswanath
>>
>>
>
> Let's say we have three ports sp1, sp2, sp3 and two VLANs 10 and 20.
> VLAN 10 is allowed on ports sp1 and sp2 and VLAN 20 is allowed on ports sp2 and sp3.
> Let's say sp1 and sp3 are access ports and carry untagged traffic. Sp2 is an uplink trunk port and carries tagged traffic.
>
> This could be modeled using Linux bridge in at least two ways:
>
> 1) Bridge per VLAN
>         - Two bridge devices are used br10 and br20
>         - sp2.10 is a vlan interface on sp2 for VLAN 10
>         - sp2.20 is a vlan interface on sp2 for VLAN 20
>         - br10 enslaves ports sp1 and sp2.10
>         - br20 enslaves ports sp3 and sp2.20
>         - br10 and br20 could be L3 interfaces and have IP address assigned to.
>                  This allows for routing between VLANs.
>         - Traffic sent to br10 will egress untagged on sp1 and tagged with VID=10 on sp2
>         - Traffic sent to br20 will egress untagged on sp2 and tagged with VID=20 on sp2
>         - Traffic received on sp1 is delivered to br10 and could be flooded if MAC DA is broadcast or unknown unicast.
>         - Traffic received on sp2 with VID=10 is delivered to br10 after the VLAN tag is removed.
>         - Similarly traffic receive on sp3 or tagged traffic with VID=20 on sp2 is delivered to br20

Thanks for the explanation. Understood this, and this is how I
saw/implemented things so far. However, my understanding is that both
br10 and br20 have nothing to do with vlan 10 and 20 respectively. The
traffic the actual bridges see (say if we ran tcpdump on br10 or br20)
is always untagged. The tagging happens while the packets are
egressing the sp2 port. In that sense, there is no vlan associated
with either of the bridges.

What I was not sure was about how we can associate a vlan with such a
bridge in this case, and what it really means for the traffic.

>
> 2) Single bridge with VLAN filtering
>         - A single bridge device br0 is used
>         - All ports sp1, sp2, and sp3 are enslaved to the bridge
>         - br0 allows both VID=10 and VID=20
>         - VLAN policy on the ports determines the bridging domains within the bridge
>                 - sp1 allows VID=10, it is untagged on egress, and it is the PVID of sp1.
>                   Linux does not provide a way to only allow untagged traffic to enter a port.
>                   Both tagged traffic with VID=10 and untagged traffic are considered received on VLAN 10.
>                 - sp3 allows VID=20, it is untagged on egress, and it is the PVID of sp2.
>                 - sp2 allows VID=10 and VID=20, both are tagged on egress, and there is no PVID so untagged traffic received on sp2 is dropped.
>
>         - Above configuration is sufficient for L2 switching with two distinct VLANs.
>         - L3 routing across VLANs in this model is achieved by vlan interfaces on the bridge. br0.10 for VLAN 10 and br0.20 for VLAN 20.
>         - br0.10 and br0.20 are L3 interfaces and have IP addresses assigned.
>                 - br0.10 allows VID=10

In this case am I correct in assuming that br0 actually represents the
switch device ? I don't see a way in which one more such bridge can
exist, since the forwarding decisions are handled at the switch-device
level.

Thanks
Viswanath

>
>
>> >
>> >
>> >> [...]
>> >>
>> >> I'll need to think about the l3 stuff but I think Jiri/Scott/Roopa
>> >> might have worked some of it out.
>> >>
>> >> --
>> >> John Fastabend         Intel Corporation
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" in
>> > the body of a message to majordomo@vger.kernel.org More majordomo
>> info
>> > at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
>> of a message to majordomo@vger.kernel.org More majordomo info at
>> http://vger.kernel.org/majordomo-info.html
