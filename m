From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net 0/4] bridge: Fix problems around the PVID
Date: Fri, 11 Oct 2013 16:34:13 +0900
Message-ID: <1381476853.3172.40.camel@ubuntu-vm-makita>
References: <1378808874.3988.2.camel@ubuntu-vm-makita>
	 <20130912.160033.779509034953932316.davem@davemloft.net>
	 <1379074013.1678.16.camel@localhost.localdomain>
	 <523744A6.5090001@redhat.com> <1379405552.6177.31.camel@ubuntu-vm-makita>
	 <524052FC.5010301@redhat.com> <1380023107.3162.53.camel@ubuntu-vm-makita>
	 <52419509.1020103@redhat.com>
	 <1380043818.4391.26.camel@localhost.localdomain>
	 <5241D20C.3060500@redhat.com> <1380191899.3716.31.camel@ubuntu-vm-makita>
	 <52444322.40408@redhat.com>
	 <1380301914.1734.63.camel@localhost.localdomain>
	 <5245C9FB.90307@redhat.com> <1380541619.3211.39.camel@ubuntu-vm-makita>
	 <5249A03E.4080208@redhat.com> <1380628602.3150.59.camel@ubuntu-vm-makita>
	 <52556FCB.70904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <toshiaki.makita1@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:47333 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754926Ab3JKHef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 03:34:35 -0400
In-Reply-To: <52556FCB.70904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-09 at 11:01 -0400, Vlad Yasevich wrote:
> On 10/01/2013 07:56 AM, Toshiaki Makita wrote:
> > On Mon, 2013-09-30 at 12:01 -0400, Vlad Yasevich wrote:
> >> On 09/30/2013 07:46 AM, Toshiaki Makita wrote:
> >>> On Fri, 2013-09-27 at 14:10 -0400, Vlad Yasevich wrote:
> >>>> On 09/27/2013 01:11 PM, Toshiaki Makita wrote:
> >>>>> On Thu, 2013-09-26 at 10:22 -0400, Vlad Yasevich wrote:
> >>>>>> On 09/26/2013 06:38 AM, Toshiaki Makita wrote:
> >>>>>>> On Tue, 2013-09-24 at 13:55 -0400, Vlad Yasevich wrote:
> >>>>>>>> On 09/24/2013 01:30 PM, Toshiaki Makita wrote:
> >>>>>>>>> On Tue, 2013-09-24 at 09:35 -0400, Vlad Yasevich wrote:
> >>>>>>>>>> On 09/24/2013 07:45 AM, Toshiaki Makita wrote:
> >>>>>>>>>>> On Mon, 2013-09-23 at 10:41 -0400, Vlad Yasevich
> >>>>>>>>>>> wrote:
> >>>>>>>>>>>> On 09/17/2013 04:12 AM, Toshiaki Makita wrote:
> >>>>>>>>>>>>> On Mon, 2013-09-16 at 13:49 -0400, Vlad Yasevich
> >>>>>>>>>>>>> wrote:
> >>>>>>>>>>>>>> On 09/13/2013 08:06 AM, Toshiaki Makita wrote:
> >>>>>>>>>>>>>>> On Thu, 2013-09-12 at 16:00 -0400, David
> >>>>>>>>>>>>>>> Miller wrote:
> >>>>>>>>>>>>>>>> From: Toshiaki Makita
> >>>>>>>>>>>>>>>> <makita.toshiaki@lab.ntt.co.jp> Date: Tue,
> >>>>>>>>>>>>>>>> 10 Sep 2013 19:27:54 +0900
> >>>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>>>> There seem to be some undesirable
> >>>>>>>>>>>>>>>>> behaviors related with PVID. 1. It has no
> >>>>>>>>>>>>>>>>> effect assigning PVID to a port. PVID
> >>>>>>>>>>>>>>>>> cannot be applied to any frame regardless
> >>>>>>>>>>>>>>>>> of whether we set it or not. 2. FDB
> >>>>>>>>>>>>>>>>> entries learned via frames applied PVID
> >>>>>>>>>>>>>>>>> are registered with VID 0 rather than VID
> >>>>>>>>>>>>>>>>> value of PVID. 3. We can set 0 or 4095 as
> >>>>>>>>>>>>>>>>> a PVID that are not allowed in IEEE
> >>>>>>>>>>>>>>>>> 802.1Q. This leads interoperational
> >>>>>>>>>>>>>>>>> problems such as sending frames with VID
> >>>>>>>>>>>>>>>>> 4095, which is not allowed in IEEE
> >>>>>>>>>>>>>>>>> 802.1Q, and treating frames with VID 0 as
> >>>>>>>>>>>>>>>>> they belong to VLAN 0, which is expected
> >>>>>>>>>>>>>>>>> to be handled as they have no VID
> >>>>>>>>>>>>>>>>> according to IEEE 802.1Q.
> >>>>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>>>> Note: 2nd and 3rd problems are potential
> >>>>>>>>>>>>>>>>> and not exposed unless 1st problem is
> >>>>>>>>>>>>>>>>> fixed, because we cannot activate PVID
> >>>>>>>>>>>>>>>>> due to it.
> >>>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>>> Please work out the issues in patch #2 with
> >>>>>>>>>>>>>>>> Vlad and resubmit this series.
> >>>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>>> Thank you.
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>> I'm hovering between whether we should fix
> >>>>>>>>>>>>>>> the issue by changing vlan 0 interface
> >>>>>>>>>>>>>>> behavior in 8021q module or enabling a bridge
> >>>>>>>>>>>>>>> port to sending priority-tagged frames, or
> >>>>>>>>>>>>>>> another better way.
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>> If you could comment it, I'd appreciate it
> >>>>>>>>>>>>>>> :)
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>> BTW, I think what is discussed in patch #2 is
> >>>>>>>>>>>>>>> another problem about handling priority-tags,
> >>>>>>>>>>>>>>> and it exists without this patch set
> >>>>>>>>>>>>>>> applied. It looks like that we should prepare
> >>>>>>>>>>>>>>> another patch set than this to fix that
> >>>>>>>>>>>>>>> problem.
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>> Should I include patches that fix the
> >>>>>>>>>>>>>>> priority-tags problem in this patch set and
> >>>>>>>>>>>>>>> resubmit them all together?
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>
> >>>>>>>>>>>>>> I am thinking that we might need to do it in
> >>>>>>>>>>>>>> bridge and it looks like the simplest way to do
> >>>>>>>>>>>>>> it is to have default priority regeneration
> >>>>>>>>>>>>>> table (table 6-5 from 802.1Q doc).
> >>>>>>>>>>>>>>
> >>>>>>>>>>>>>> That way I think we would conform to the spec.
> >>>>>>>>>>>>>>
> >>>>>>>>>>>>>> -vlad
> >>>>>>>>>>>>>
> >>>>>>>>>>>>> Unfortunately I don't think the default priority
> >>>>>>>>>>>>> regeneration table resolves the problem because
> >>>>>>>>>>>>> IEEE 802.1Q says that a VLAN-aware bridge can
> >>>>>>>>>>>>> transmit untagged or VLAN-tagged frames only (the
> >>>>>>>>>>>>> end of section 7.5 and 8.1.7).
> >>>>>>>>>>>>>
> >>>>>>>>>>>>> No mechanism to send priority-tagged frames is
> >>>>>>>>>>>>> found as far as I can see the standard. I think
> >>>>>>>>>>>>> the regenerated priority is used for outgoing
> >>>>>>>>>>>>> PCP field only if egress policy is not untagged
> >>>>>>>>>>>>> (i.e. transmitting as VLAN-tagged), and unused if
> >>>>>>>>>>>>> untagged (Section 6.9.2 3rd/4th Paragraph).
> >>>>>>>>>>>>>
> >>>>>>>>>>>>> If we want to transmit priority-tagged frames
> >>>>>>>>>>>>> from a bridge port, I think we need to implement
> >>>>>>>>>>>>> a new (optional) feature that is above the
> >>>>>>>>>>>>> standard, as I stated previously.
> >>>>>>>>>>>>>
> >>>>>>>>>>>>> How do you feel about adding a per-port policy
> >>>>>>>>>>>>> that enables a bridge to send priority-tagged
> >>>>>>>>>>>>> frames instead of untagged frames when egress
> >>>>>>>>>>>>> policy for the port is untagged? With this
> >>>>>>>>>>>>> change, we can transmit frames for a given vlan
> >>>>>>>>>>>>> as either all untagged, all priority-tagged or
> >>>>>>>>>>>>> all VLAN-tagged.
> >>>>>>>>>>>>
> >>>>>>>>>>>> That would work.  What I am thinking is that we do
> >>>>>>>>>>>> it by special casing the vid 0 egress policy
> >>>>>>>>>>>> specification.  Let it be untagged by default and
> >>>>>>>>>>>> if it is tagged, then we preserve the priority
> >>>>>>>>>>>> field and forward it on.
> >>>>>>>>>>>>
> >>>>>>>>>>>> This keeps the API stable and doesn't require
> >>>>>>>>>>>> user/admin from knowing exactly what happens.
> >>>>>>>>>>>> Default operation conforms to the spec and allows
> >>>>>>>>>>>> simple change to make it backward-compatible.
> >>>>>>>>>>>>
> >>>>>>>>>>>> What do you think.  I've done a simple prototype of
> >>>>>>>>>>>> this an it seems to work with the VMs I am testing
> >>>>>>>>>>>> with.
> >>>>>>>>>>>
> >>>>>>>>>>> Are you saying that - by default, set the 0th bit of
> >>>>>>>>>>> untagged_bitmap; and - if we unset the 0th bit and
> >>>>>>>>>>> set the "vid"th bit, we transmit frames classified as
> >>>>>>>>>>> belonging to VLAN "vid" as priority-tagged?
> >>>>>>>>>>>
> >>>>>>>>>>> If so, though it's attractive to keep current API,
> >>>>>>>>>>> I'm worried about if it could be a bit confusing and
> >>>>>>>>>>> not intuitive for kernel/iproute2 developers that VID
> >>>>>>>>>>> 0 has a special meaning only in the egress policy.
> >>>>>>>>>>> Wouldn't it be better to adding a new member to
> >>>>>>>>>>> struct net_port_vlans instead of using VID 0 of
> >>>>>>>>>>> untagged_bitmap?
> >>>>>>>>>>>
> >>>>>>>>>>> Or are you saying that we use a new flag in struct
> >>>>>>>>>>> net_port_vlans but use the BRIDGE_VLAN_INFO_UNTAGGED
> >>>>>>>>>>> bit with VID 0 in netlink to set the flag?
> >>>>>>>>>>>
> >>>>>>>>>>> Even in that case, I'm afraid that it might be
> >>>>>>>>>>> confusing for developers for the same reason. We are
> >>>>>>>>>>> going to prohibit to specify VID with 0 (and 4095) in
> >>>>>>>>>>> adding/deleting a FDB entry or a vlan filtering
> >>>>>>>>>>> entry, but it would allow us to use VID 0 only when a
> >>>>>>>>>>> vlan filtering entry is configured. I am thinking a
> >>>>>>>>>>> new nlattr is a straightforward approach to
> >>>>>>>>>>> configure it.
> >>>>>>>>>>
> >>>>>>>>>> By making this an explicit attribute it makes vid 0 a
> >>>>>>>>>> special case for any automatic tool that would
> >>>>>>>>>> provision such filtering.  Seeing vid 0 would mean that
> >>>>>>>>>> these tools would have to know that this would have to
> >>>>>>>>>> be translated to a different attribute instead of
> >>>>>>>>>> setting the policy values.
> >>>>>>>>>
> >>>>>>>>> Yes, I agree with you that we can do it by the way you
> >>>>>>>>> explained. What I don't understand is the advantage of
> >>>>>>>>> using vid 0 over another way such as adding a new
> >>>>>>>>> nlattr. I think we can indicate transmitting
> >>>>>>>>> priority-tags explicitly by such a nlattr. Using vid 0
> >>>>>>>>> seems to be easier to implement than a new nlattr, but,
> >>>>>>>>> for me, it looks less intuitive and more difficult to
> >>>>>>>>> maintain because we have to care about vid 0 instead of
> >>>>>>>>> simply ignoring it.
> >>>>>>>>>
> >>>>>>>>
> >>>>>>>> The point I am trying to make is that regardless of the
> >>>>>>>> approach someone has to know what to do when enabling
> >>>>>>>> priority tagged frames.  You proposal would require the
> >>>>>>>> administrator or config tool to have that knowledge.
> >>>>>>>> Example is: Admin does: bridge vlan set priority on dev
> >>>>>>>> eth0 Automated app: if (vid == 0) /* Turn on priority
> >>>>>>>> tagged frame support */
> >>>>>>>>
> >>>>>>>> My proposal would require the bridge filtering
> >>>>>>>> implementation to have it. user tool: bridge vlan add vid 0
> >>>>>>>> tagged Automated app:  No special case.
> >>>>>>>>
> >>>>>>>> IMO its better to have 1 piece code handling the special
> >>>>>>>> case then putting it multiple places.
> >>>>>>>
> >>>>>>> Thank you for the detailed explanation. Now I understand your
> >>>>>>> intention.
> >>>>>>>
> >>>>>>> I have one question about your proposal. I guess the way to
> >>>>>>> enable priority-tagged is something like bridge vlan add vid
> >>>>>>> 10 dev eth0 bridge vlan add vid 10 dev vnet0 pvid untagged
> >>>>>>> bridge vlan add vid 0 dev vnet0 tagged where vnet0 has sub
> >>>>>>> interface vnet0.0.
> >>>>>>>
> >>>>>>> Here the admin have to know the egress policy is applied to a
> >>>>>>> frame twice in a certain order when it is transmitted from
> >>>>>>> the port vnet0 attached, that is, first, a frame with vid 10
> >>>>>>> get untagged, and then, an untagged frame get
> >>>>>>> priority-tagged.
> >>>>>>>
> >>>>>>> This behavior looks difficult to know without previous
> >>>>>>> knowledge. Any good idea to avoid such a need for the admin's
> >>>>>>> additional knowledge?
> >>>>>>
> >>>>>> To me, the fact that there is vnet0.0 (or typically, there is
> >>>>>> eth0.0 in the guest or on the remote host) already tells the
> >>>>>> admin vlan 0 has to be tagged.  The fact that we codify this in
> >>>>>> the policy makes it explicit.
> >>>>>
> >>>>> My worry is that the admin might not be able to guess how to use
> >>>>> bridge commands to enable priority-tag without any additional
> >>>>> hint in "man bridge", "bridge vlan help", etc. I actually
> >>>>> couldn't hit upon such a usage before seeing example commands you
> >>>>> gave, because I had never think the egress policy could be
> >>>>> applied twice.
> >>>>>
> >>>>>>
> >>>>>> However, I can see strong argument to be made for an addition
> >>>>>> egress policy attribute that could be for instance:
> >>>>>>
> >>>>>> bridge vlan add vid 10 dev eth0 pvid bridge vlan add vid 10 dev
> >>>>>> vnet0 pvid untagged prio_tag
> >>>>>>
> >>>>>> But this has the same connotations as wrt to egress policy.
> >>>>>> The 2 policies are applied: (1) untag the frame. (2) add
> >>>>>> priority_tag.
> >>>>>>
> >>>>>> (2) only happens if initial fame received on eth0 was priority
> >>>>>> tagged.
> >>>>>
> >>>>> If we do so, we will not be able to communicate using vlan 0
> >>>>> interface under a certain circumstance. Eth0 can be receive mixed
> >>>>> untagged and priority-tagged frames according to the network
> >>>>> element it is connected to: for example, Open vSwitch can send
> >>>>> such two kinds of frames from the same port even if original
> >>>>> incoming frames belong to the same vlan.
> >>>>
> >>>> Which priority would you assign to the frame that was received
> >>>> untagged?
> >>>
> >>> Untagged frame's priority is by default 0, so I think 0 is likely.
> >>>
> >>> 802.1Q 6.9.1 i) The received priority value and the drop_eligible
> >>> parameter value are the values in the M_UNITDATA.indication.
> >>>
> >>> M_UNITDATA is passed from ISS.
> >>>
> >>> 802.1Q 6.7.1 The priority parameter provided in a data indication
> >>> primitive shall take the value of the Default User Priority parameter
> >>> for the Port through which the MAC frame was received. The default
> >>> value of this parameter is 0, it may be set by management in which
> >>> case the capability to set it to any of the values 0 through 7 shall
> >>> be provided.
> >>>
> >>>>
> >>>>> In this situation, we can only receive frames that is
> >>>>> priority-tagged when received on eth0.
> >>>>
> >>>> Not sure I understand.  Let's look at this config: bridge vlan add
> >>>> vid 10 dev eth0 pvid bridge vlan add vid 10 dev vnet0 pvid untagged
> >>>> prio_tag
> >>>>
> >>>> Here, eth0 is allowed to receive vid 10 tagged, untagged, and
> >>>> prio_tagged (if we look at the patch 2 from this set). Now, frame
> >>>> is forwarded to vnet0. 1) if the frame had vid 10 in the tag or was
> >>>> untagged, it should probably be sent untagged. 2) if the frame had
> >>>> a priority tag, it should probably be sent as such.
> >>>>
> >>>> Now, I think a case could be made that if the frame had any
> >>>> priority markings in the vlan header, we should try to preserve
> >>>> those markings if prio_tag is turned on.  We can assume value of 0
> >>>> means not set.
> >>>
> >>> If we don't insert prio_tag when PCP is 0, we might receive mixed
> >>> priority-tagged and untagged frames on eth0.
> >>
> >> Right, and that's what you were trying to handle in your patch:
> >>
> >>> +		/* PVID is set on this port.  Any untagged or priority-tagged +
> >>> * ingress frame is considered to belong to this vlan. */
> >>
> >> So, in this case we are prepared to handle the "mixed" scenario on ingress.
> >>
> >>> Even if we are sending frames from eth0.0 with some priority other
> >>> than 0, we could receive frames with priority 0 or untagged on the
> >>> other side of the bridge.
> >>> For example, if we receive untagged arp reply on the bridge port, we
> >>> migit not be able to communicate with such an end station, because
> >>> untagged reply will not be passed to eth0.0.
> >>
> >> So the ARP request was sent tagged, but the reply came back untagged?
> >
> > Yes, it can happen.
> > These are problematic cases.
> >
> > Example 1:
> >              prio_tagged         prio_tagged
> > +------------+ ---> +------------+ ---> +----------+
> > |guest eth0.0|------|host1 Bridge|------|host2 eth0|
> > +------------+ <--- +------------+ <--- +----------+
> >               untagged            untagged
> >
> > Note: Host2 eth0, which is an interface on Linux, can receive
> > priority-tagged frames if it doesn't have vlan 0 interface (eth0.0).
> 
> Hmm..  Just to see if this works, I ran the this scenario with
> a dumb switch in the middle, and it did not work as you noted.
> I then realized that one of the kernels was rather old and after 
> updating it, behaved differently.  The communication still didn't
> work, but host2 behaved properly.
> 
> >>
> >> How does that work when the end station is attached directly to the
> >> HW switch instead of a linux bridge?
> >>
> >> The station configures eth0.0 and sends priority-tagged traffic to
> >> the HW switch.  If the HW switch sends back untagged traffic, then
> >> the untagged traffic will never reach eth0.0.
> >
> > Currently we cannot communicate using eth0.0 via directly connected
> > 802.1Q conformed switch, because we never receive priority-tagged frames
> > from the switch.
> > It is not a problem of Linux bridge and is why I wondered whether it
> > should be fixed by bridge or vlan 0 interface.
> >
> >>
> >>>
> >>>>
> >>>>> IMO, if prio_tag is configured, the bridge should send any
> >>>>> untagged frame as priority-tagged regardless of whatever it is on
> >>>>> eth0.
> >>>>
> >>>> Which priority would you use, 0?  You are not guaranteed to
> >>>> properly deliver the traffic then for a configuration such as: VM:
> >>>> eth0: 10.0.0.1/24 eth0.0: 10.0.1.1/24
> >>>
> >>> I'd like to use priority 0 for untagged frames.
> >>>
> >>> I am assuming that one of our goals is at least that eth0.0 comes to
> >>> be able to communicate with another end station. It seems to be hard
> >>> to use both eth0 and eth0.0 simultaneously.
> >>
> >> I understand, but I don't agree that we should always tag.
> >>
> >> Consider config:
> >>
> >>      hw switch <---> (eth0: Linux Bridge: eth1) <--- (em1.0:end station)
> >>
> >> If the end station sends priority-tagged traffic it should receive
> >> priority tagged traffic back.  Otherwise, untagged traffic may be
> >> dropped by the end station.  This is true whether it is connected to
> >> the hw switch or Linux bridge.
> >
> > Though such a behavior is generally not necessary as far as I can read
> > 802.1Q spec, it is essential for vlan 0 interface on Linux, I think.
> > My proposal aims to resolve it at least when we use Linux bridge.
> >
> > Example configuration:
> > 	bridge vlan add vid 10 dev eth1 pvid untagged
> > 	bridge vlan add vid 10 dev eth0
> > 	bridge vlan set prio_tag on dev eth1
> >
> > Intended behavior:
> >
> >          VID10-tagged                     prio_tagged
> > +---------+ <--- +------------------------+ <--- +-----------------+
> > |hw switch|------|eth0: Linux Bridge: eth1|------|em1.0:end station|
> > +---------+ ---> +------------------------+ ---> +-----------------+
> >          VID10-tagged                     prio_tagged
> >                                (always if egress policy untagged)
> 
> Ok, I think you've convinced me that this is the right approach. The 
> only thing that I am not crazy about is the API.  I'd almost want to
> introduce a new flag that can be set in a 'vlan add' or 'vlan set'
> command that communicates a new policy.

I'm glad that we reached a consensus on the approach :)

I agree with you that the API is flag based.
I'm guessing your intention is that 'vlan add' means a per vlan per port
policy and 'vlan set' means a per port one, that is,
	'vlan add': bridge vlan add vid 10 dev eth1 prio_tag
	'vlan set': bridge vlan set prio_tag on dev eth1

I think they can behave differently only when we set untagged to
multiple vlans on the same port.

'vlan add' example with vid 10 and 20:
	bridge vlan add vid 10 dev eth1 pvid untagged prio_tag
	bridge vlan add vid 10 dev eth0
	bridge vlan add vid 20 dev eth1 untagged
	bridge vlan add vid 20 dev eth2

         VID10-tagged                  prio_tagged (from eth0)
+---------+ ---> +------------------------+ ---> +-----------------+
|hw switch|------|eth0                eth1|------|em1.0:end station|
+---------+      |      Linux Bridge      | ---> +-----------------+
+---------+      |                        | *untagged*
|hw switch|------|eth2                    | (from eth2)
+---------+ ---> +------------------------+
         VID20-tagged


'vlan set' example with vid 10 and 20:
	bridge vlan add vid 10 dev eth1 pvid untagged
	bridge vlan add vid 10 dev eth0
	bridge vlan add vid 20 dev eth1 untagged
	bridge vlan add vid 20 dev eth2
	bridge vlan set prio_tag on dev eth1

         VID10-tagged                  prio_tagged (from eth0)
+---------+ ---> +------------------------+ ---> +-----------------+
|hw switch|------|eth0                eth1|------|em1.0:end station|
+---------+      |      Linux Bridge      | ---> +-----------------+
+---------+      |                        | prio_tagged
|hw switch|------|eth2                    | (from eth2)
+---------+ ---> +------------------------+
         VID20-tagged

Em1.0 can always receive traffic from eth1 if we adopt 'vlan set'.
However, I cannot imagine when multiple untagged vlans is required, so
cannot figure out whether 'vlan add' is useful or harmful.
Anyway, both of approaches are OK with me.

Thanks,
Toshiaki Makita

> 
> Thanks
> -vlad
> 
> >
> > Thanks,
> >
> > Toshiaki Makita
> >
> >>
> >> -vlad
> >>
> >>>
> >>> Thanks,
> >>>
> >>> Toshiaki Makita
> >>>
> >>>>
> >>>> -vlad
> >>>>
> >>>>>
> >>>>>>
> >>>>>> I think I am ok with either approach.  Explicit vid 0 policy is
> >>>>>> easier for automatic provisioning.   The flag based one is
> >>>>>> easier for admin/ manual provisioning.
> >>>>>
> >>>>> Supposing we have to add something to help or man in any case, I
> >>>>> think flag based is better. The format below seems to suitable
> >>>>> for a per-port policy. bridge vlan set prio_tag on dev vnet0
> >>>>>
> >>>>> Thanks,
> >>>>>
> >>>>> Toshiaki Makita
> >>>>>
> >>>>>>
> >>>>>> -vlad.
> >>>>>>
> >>>>>> -vlad
> >>>>>>
> >>>>>>
> >>>>>>
> >>>>>>
> >>>>>>>
> >>>>>>>>
> >>>>>>>> Thanks -vlad
> >>>>>>>>
> >>>>>>>>> Thanks,
> >>>>>>>>>
> >>>>>>>>> Toshiaki Makita
> >>>>>>>>>
> >>>>>>>>>>
> >>>>>>>>>> How it is implemented internally in the kernel isn't as
> >>>>>>>>>> big of an issue. We can do it as a separate flag or as
> >>>>>>>>>> part of existing policy.
> >>>>>>>>>>
> >>>>>>>>>> -vlad
> >>>>>>>>>>
> >>>>>>>>>>>
> >>>>>>>>>>> Thanks,
> >>>>>>>>>>>
> >>>>>>>>>>> Toshiaki Makita
> >>>>>>>>>>>
> >>>>>>>>>>>>
> >>>>>>>>>>>> -vlad
> >>>>>>>>>>>>
> >>>>>>>>>>>>>
> >>>>>>>>>>>>> Thanks,
> >>>>>>>>>>>>>
> >>>>>>>>>>>>> Toshiaki Makita
> >>>>>>>>>>>>>
> >>>>>>>>>>>>>>
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>> Thanks,
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>> Toshiaki Makita
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>>> -- To unsubscribe from this list: send the
> >>>>>>>>>>>>>>>> line "unsubscribe netdev" in the body of a
> >>>>>>>>>>>>>>>> message to majordomo@vger.kernel.org More
> >>>>>>>>>>>>>>>> majordomo info at
> >>>>>>>>>>>>>>>> http://vger.kernel.org/majordomo-info.html
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>
> >>>>>>>>>>>>>
> >>>>>>>>>>>>> -- To unsubscribe from this list: send the line
> >>>>>>>>>>>>> "unsubscribe netdev" in the body of a message to
> >>>>>>>>>>>>> majordomo@vger.kernel.org More majordomo info at
> >>>>>>>>>>>>> http://vger.kernel.org/majordomo-info.html
> >>>>>>>>>>>>>
> >>>>>>>>>>>
> >>>>>>>>>>>
> >>>>>>>>>>
> >>>>>>>>>
> >>>>>>>>>
> >>>>>>>
> >>>>>>>
> >>>>>>
> >>>>>
> >>>>>
> >>>
> >>>
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
