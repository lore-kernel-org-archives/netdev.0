From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 2 Apr 2014 09:47:44 -0700
Message-ID: <CAGVrzcZCU+fMQ0XwNa-3j3ATtSu4rDxL=+Hcwc4nTUj89A8ZZw@mail.gmail.com>
References: <20140325193533.GF8102@hmsreliant.think-freely.org>
 <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com>
 <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com>
 <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion>
 <533312A3.5070600@cumulusnetworks.com> <20140326180356.GK2869@minipsycho.orion>
 <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
 <533C1F91.6000704@greyhouse.net> <20140402152546.GB3596@tuxdriver.com> <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:53226 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932419AbaDBQsZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 12:48:25 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so446132pab.41
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 09:48:25 -0700 (PDT)
In-Reply-To: <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-02 9:15 GMT-07:00 Scott Feldman <sfeldma@cumulusnetworks.com>:
>
> On Apr 2, 2014, at 8:25 AM, John W. Linville <linville@tuxdriver.com>=
 wrote:
>
>> On Wed, Apr 02, 2014 at 10:32:49AM -0400, Andy Gospodarek wrote:
>>> On 04/01/2014 03:13 PM, Scott Feldman wrote:
>>>> On Mar 26, 2014, at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>
>>>>> Wed, Mar 26, 2014 at 06:47:15PM CET, roopa@cumulusnetworks.com wr=
ote:
>>>>>> On 3/26/14, 9:59 AM, Jiri Pirko wrote:
>>>>>>> Wed, Mar 26, 2014 at 05:54:17PM CET, roopa@cumulusnetworks.com =
wrote:
>>>>>>> So you implement bonding netlink api? Or you hook into bonding =
driver
>>>>>>> itselt? Can you show us the code?
>>>>>> We use the netlink API and libnl. In our current model, our swit=
ch
>>>>>> chip driver listens to netlink notifications and programs the sw=
itch
>>>>>> chip. The switch chip driver uses libnl caches and libnl netlink=
 apis
>>>>>> to reflect the kernel state to switch chip.
>>>>>
>>>>> So when you configure for example bonding over 2 ports, you actua=
lly use
>>>>> bonding driver to do that. And you userspace app listens to
>>>>> notifications and programs the switch chip accordingly. Am I clos=
e?
>>>>>
>>>>> How about data? Is this new "bonding" interface able to assign ip=
 to is
>>>>> and send/receive packets.
>>>>>
>>>>> I'm still not sure I understand your concept. Do you have some
>>>>> documentation for it available?
>>>> Actually Jiri this is the code you and I worked on recently to net=
link-ify bonding/slave attributes and active/inactive notification.  Yo=
u have it right, user uses normal ip link tools and bonding driver to c=
reate bond, set attributes, and enslave switch ports.  RTM_NEWLINK is u=
sed to program ASIC to offload LAG to HW.  RTM_NEWLINK msgs contains bo=
nd attributes (mode, etc) and slave list, as well as slave status.  Thi=
s is enough information to program ASIC.  Once programmed, ASIC offload=
s the data plane traffic, and in the case of egress, handles the LAG ha=
sh distribution.  Only the LACP control plane traffic makes it to the b=
onding driver; data plane traffic does not make it to the bonding drive=
r.
>>>>
>>>> So, not trying to sound like a smart-ass, but the documentation is=
 the bonding driver, specifically the netlink attributes/notifications.
>>>>
>>>> -scott
>>>
>>> Using netlink messages to notify drivers for these ASICs really
>>> seems like a great way to handle things.  It would obviously requir=
e
>>> some expansion of netlink, but that seems fine.
>>>
>>> I would prefer that ASIC vendors write initial drivers for their
>>> ASICs such that each physical port is detected and exported as a
>>> netdev.  This would mean each *minimal* kernel driver for an ASIC
>>> would need to have support for the following (off the top of my
>>> head):
>>>
>>> - detect link status on an interface
>>> - set an interface's MAC address
>>> - configure the chip to send all frames to the CPU
>>> - register a napi handler for the interfaces (depending on
>>> packet-buffering capabilities in the hardware)
>>>
>>> As support for new hardware capabilities are moved from switch
>>> vendor SDKs to their kernel driver the driver can begin to listen
>>> for netlink messages that:
>>>
>>> - setup bonds/teams
>>> - add ports to bridge groups
>>> - configure port-based or mac-based VLANs
>>> - add unicast and multicast entries
>>> - add and remove entries from a flow table
>>> - ...
>>>
>>> Maybe this all seems to matter-of-fact and the discussion has
>>> evolved well beyond something this high-level, but there still seem=
s
>>> to be significant discussion about whether or not the ASIC should b=
e
>>> exported as a netdev and I'm just not seeing a compelling reason.
>>> This was my attempt to explain why.  :)
>>
>> Andy and I discussed this off-line, so I am admittedly partial to
>> the conclusions we shared as reflected above... :-)
>>
>> While I might be convinced that there should be _something_ to
>> represent the switch chip for some purpose (e.g. topology mapping),
>> I'm not at all convinced that thing should be a netdev.  I don't see
>> where the switch chip by itself looks much like any other netdev at
>> all, especially once you model the actual front-panel ports with
>> their own netdevs.  I do know that having an extra "magic netdev"
>> in the wireless space added a lot of confusion for no clear gain,
>> leading to it later being abolished.
>>
>> Modeling at the switch level might make more sense from a flow
>> management perspective?  But if those flows are managed using a netl=
ink
>> protocol, does it matter what sort of entity is listening and acting
>> on those messages?  If a switch-specific interface is needed for tha=
t,
>> we should build it rather than pretending it looks like a netdev.
>> I also think that throwing the DSA switches in with flow-based and
>> "Enterprise" switches may just be confusing things.
>>
>> I think that the opening bid should be a minimal hardware driver tha=
t
>> models each front-panel port with a netdev and passes all traffic
>> to/from the CPU.  Intelligence beyond that should be added on a
>> 'can-do' basis, with individual drivers (or corresponding userland
>> components) listening to existing netlink traffic and implementing
>> support for existing protocols to the best of their abilities.
>> Missing functionality in the netlink protocols or other functions
>> (e.g. bonding, bridging, etc) can be evolved over time as we discove=
r
>> missing bits required for switch acceleration.
>
> I agree completely with your/Andy=E2=80=99s view.  It=E2=80=99s the s=
witch port, not the switch, that needs to be modeled as a netdev.  The =
switch port is the abstraction that allows other existing virtual devic=
es (bridges, bond, vxlans, etc) to cuddle against.  Is a switch port a =
special netdev in some way?  At a high level, not really.  I mean in se=
nse it=E2=80=99s just eth48 on a super NIC.  OK, there may be some adva=
ntage to setting a IFF_SWITCH_PORT on the switch port netdev, so cuddli=
ng netdevs could get a hint that their data plane might be offloaded.
>
> I=E2=80=99ve been back-and-forth on the switch netdev.  Today I=E2=80=
=99m not for it.  But I=E2=80=99m still searching for a reason.  At one=
 point I thought a switch netdev would be nice in a L3 router case wher=
e we needed a router IP address to do things like OSPF unnumbered inter=
faces, but even in that case, we can just put the router IP on lo.  Ano=
ther reason would be to use the switch netdev as a place for switch-wid=
e settings and status.  For example,
> ethtool -S stats on switch netdev would show switch-wide stats like A=
CL drops or something like that.  Maybe a switch device is modeled as a=
 new device class?  I guess it comes down to how much is duplicated bet=
ween different vendors' switch driver implementations.

I think the idea behind exposing a switch net_device is to account for
all special cases where there is not already an existing and
well-defined model for switch-wide events/control/information that we
might want to have. Why a net_device, because the switch ports will
already be exposed as such, so mostly for consistency with the
presented user-space interface. Whether that net_device exposes
different child devices of different classes, e.g: MTD partitions to
access firmware updates, SPI master/slave controller(s), MDIO
controller(s), is yet to be defined I suppose.

>
> Agree on the missing netlink functionality point, add it as we go.  O=
utside the bonding stuff we recently added, we (Cumulus) find netlink p=
retty complete as-is to program modern, enterprise-class switch chips.
>
> -scott
>
>
>



--=20
=46lorian
