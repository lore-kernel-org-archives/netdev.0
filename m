From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 08/16] net/devlink: Add E-Switch mode control
Date: Thu, 30 Jun 2016 17:53:14 +0200
Message-ID: <20160630155314.GG2569@nanopsycho.orion>
References: <CAJ3xEMgGCW_P-sb3pe1KqMVoKe4BWKoO88_O364nwEU6bDnaoA@mail.gmail.com>
 <577446FE.7060402@gmail.com>
 <5774938D.7010902@gmail.com>
 <57749A57.1030709@gmail.com>
 <20160630062516.GA2569@nanopsycho.orion>
 <5774C6B3.1000901@intel.com>
 <20160630074154.GC2569@nanopsycho.orion>
 <5774D0E1.4070605@gmail.com>
 <20160630105212.GD2569@nanopsycho.orion>
 <57753D89.3030904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37240 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690AbcF3Pxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:53:44 -0400
Received: by mail-wm0-f46.google.com with SMTP id a66so125039239wme.0
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 08:53:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57753D89.3030904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 30, 2016 at 05:40:57PM CEST, john.fastabend@gmail.com wrote:
>On 16-06-30 03:52 AM, Jiri Pirko wrote:
>> Thu, Jun 30, 2016 at 09:57:21AM CEST, john.fastabend@gmail.com wrote:
>>> On 16-06-30 12:41 AM, Jiri Pirko wrote:
>>>> Thu, Jun 30, 2016 at 09:13:55AM CEST, sridhar.samudrala@intel.com wrote:
>>>>>
>>>>>
>>>>> On 6/29/2016 11:25 PM, Jiri Pirko wrote:
>>>>>> Thu, Jun 30, 2016 at 06:04:39AM CEST, john.fastabend@gmail.com wrote:
>>>>>>> On 16-06-29 08:35 PM, John Fastabend wrote:
>>>>>>>> On 16-06-29 03:09 PM, John Fastabend wrote:
>>>>>>>>> On 16-06-29 02:33 PM, Or Gerlitz wrote:
>>>>>>>>>> On Wed, Jun 29, 2016 at 7:35 PM, John Fastabend
>>>>>>>>>> <john.fastabend@gmail.com> wrote:
>>>>>>>>>>> On 16-06-29 07:48 AM, Or Gerlitz wrote:
>>>>>>>>>>>> On 6/28/2016 10:31 PM, John Fastabend wrote:
>>>>>>>>>>>>> On 16-06-28 12:12 PM, Jiri Pirko wrote:
>>>>>>>>>>>>>> Why?! Please, leave legacy be legacy. Use the new mode for
>>>>>>>>>>>>>> implementing new features. Don't make things any more complicated :(
>>>>>>>>>> [...]
>>>>>>>>>>>>> Maybe I'm reading to much into the devlink flag names and if instead
>>>>>>>>>>>>> you use a switch like the following,
>>>>>>>>>>>>>    VF representer : enable/disable the creation VF netdev's to represent
>>>>>>>>>>>>>                     the virtual functions on the PF
>>>>>>>>>>>>> Much less complicated then magic switching between forwarding logic IMO
>>>>>>>>>>>>> and you don't whack a default configuration that an entire stack (e.g.
>>>>>>>>>>>>> libvirt) has been built to use.
>>>>>>>>>>>> Re letting the user to observe/modify the rules added by the
>>>>>>>>>>>> driver/firmware while legacy mode. Even if possible with bridge/fdb, it
>>>>>>>>>>>> will be really pragmatical and doesn't make sense to get that donefor
>>>>>>>>>>>> the TC subsystem. So this isn't a well defined solution and anyway, as
>>>>>>>>>>>> you said, legacy mode enhancements is a different exercise. Personally,
>>>>>>>>>>>> I agree with Jiri, that we should legacy be legacyand focus on adding
>>>>>>>>>>>> the new model.
>>>>>>>>>>> The ixgbe driver already supports bridge and tc commands without the VF
>>>>>>>>>>> representer.  Adding the VF representer to these drivers just extends
>>>>>>>>>>> the existing support so we have an identifier for VFs and now the
>>>>>>>>>>> redirect action works and the fdb commands can specify the VF netdevs.
>>>>>>>>>>> I don't see this as a problem because we already do it today with
>>>>>>>>>>> 'ip' and bridge tools.
>>>>>>>>>> To be precise, for both ixgbe and mlx5, the existing tc support
>>>>>>>>>> (u32/ixgbe, flower/mlx5) is not for switching functionality but rather
>>>>>>>>>> for NIC-ish one, e.g drop, mark, etc. Indeed in ixgbe you added
>>>>>>>>>> redirect to VF, but this is only for south --> north (wire --> VF)
>>>>>>>>>> traffic, w.o the VF rep you can't do the other way around.
>>>>>>>>>>
>>>>>>>>> Correct which is why we need the VF rep. So we are completely in
>>>>>>>>> sync there.
>>>>>>>>>
>>>>>>>>>> Just to clarify, to what exact bridge command support did you refer for ixgbe?
>>>>>>>>> 'bridge fdb' commands are supported today on the PF. But its the
>>>>>>>>> same story as above we need the VF rep to also use it on the
>>>>>>>>> VF representer
>>>>>>>>>
>>>>>>>>> Also 'bridge link' command for veb/vepa modes is supported and the
>>>>>>>>> other link attributes could be supported with additional driver
>>>>>>>>> support. No need for core changes here. But again yes only on the
>>>>>>>>> PF so again we need the VF reps.
>>>>>>>>>
>>>>>>>>>> The forwarding done in the legacy mode is not well defined, and
>>>>>>>>>> different across vendors, adding there the VF reps will not make it
>>>>>>>>>> any better b/c some steering rules will be set by tc/bridge offloads
>>>>>>>>>> while other rules will be put by the driver.
>>>>>>>>>> I don't see how this takes us to better place.
>>>>>>>>> In legacy mode or any other mode you are defining some default policy
>>>>>>>>> and rules.
>>>>>>>>>
>>>>>>>>> In the legacy mode we use mac/vlan assigned l2 forwarding entries in the
>>>>>>>>> hardware fdb which are seen when you query 'ip link' and 'bridge fdb'
>>>>>>>>> today. And similarly can be modified today using 'ip link' and 'bridge
>>>>>>>>> fdb' at least on the intel devices. Its not undefined in any way with
>>>>>>>>> a quick query of the tools we can learn exactly what the configuration
>>>>>>>>> is and even change it. This works fairly well with existing controllers
>>>>>>>>> and stacks.
>>>>>>>>>
>>>>>>>>> The limitations are 'ip' only supports a single MAC address per VF and
>>>>>>>>> 'tc' doesn't work on VF ports because when the VF is assigned to a VM
>>>>>>>>> or namespace we lose visibility of it. Providing a VF rep for this
>>>>>>>>> solves both of those problems.
>>>>>>>>>
>>>>>>>>> In this new mode the default policy is to create a default miss rule
>>>>>>>>> and implement no l2 forwarding rules. Unfortunately not all hardware
>>>>>>>>> in use supports this default miss rule case but would still benefit
>>>>>>>> >from having a VF rep. So we shouldn't make this a stipulation for
>>>>>>>>> enabling VF reps. It also changes a default policy that has been in
>>>>>>>>> place for years without IMO at least any compelling reason. It will
>>>>>>>>> be easy enough to change the default l2 policy to a flow based model
>>>>>>>>> with a few bridge/tc commands.
>>>>>>>>>
>>>>>>>>>>> We are also slightly in disagreement about what the default should be
>>>>>>>>>>> with VF netdevs. I think the default should be the same L2 mac/vlan
>>>>>>>>>>> switch behavior and see no reason to change it by default just because
>>>>>>>>>>> we added VF netdevs. The infrastructure libvirt/openstack/etc are built
>>>>>>>>>>> around this default today. But I guess nothing in this series specifies
>>>>>>>>>>> what the defaults of any given driver will be. VF netdevs are still
>>>>>>>>>>> useful even on older hardware that only supports mac/vlan forwarding to
>>>>>>>>>>> expose statistics and send/receive control frames such as lldp.
>>>>>>>>>> Again, this is not about default engineering... and using the VF reps
>>>>>>>>>> (not VF netdevs) in legacy mode only make it more cryptic to my
>>>>>>>>>> opinion. I agree some changes would be needed in openstack to support
>>>>>>>>>> the new model, but this is how progress is made... you can't always
>>>>>>>>>> make all layer above you unchanged. Note that the VF reps behave the
>>>>>>>>>> same as tap devices (v-switch doing xmit on tap --> recv in VM, VM
>>>>>>>>>> sends --> recv on tap into the v-switch), so the change in open-stack
>>>>>>>>>> would not be that big.
>>>>>>>>>>
>>>>>>>>> But in this case we have no reason to break the stack above us. The
>>>>>>>>> currently deployed usage is L2 mac/vlan. As soon as you bind a vSwitch
>>>>>>>>> or whatever mgmt agent to the device it can go ahead and manage the
>>>>>>>>> switch putting it in the correct mode using the tooling in 'bridge' and
>>>>>>>>> 'tc'.
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>> [...]
>>>>>>>>>>
>>>>>>>>>>> Why I think the VF representer is a per port ethtool flag and not a
>>>>>>>>>>> devlink option is my use case might be to assign a PF into a VM or
>>>>>>>>>>> namespace where I don't want VF netdevs.
>>>>>>>>>> again, we think the correct place to set how the eswitch is managed is
>>>>>>>>>> through eswitch manager PCI devices and not net devices and hence
>>>>>>>>>> ethtool is not the way to go.
>>>>>>>>>>
>>>>>>>>>> Also, how do you want your e-switch to be managed in this case?
>>>>>>>>>>
>>>>>>>>> In the case where I don't create vf netdevs on one of the PFs I'll
>>>>>>>>> manage the forwarding tables via the existing mechanisms 'ip' and
>>>>>>>>> 'bridge'. However its likely not a big deal because 'ip' and 'bridge'
>>>>>>>>> will continue to work even if VF reps are around. The ethtool/devlink
>>>>>>>>> comment was more about pointing out that creating VFs does not
>>>>>>>>> require you to manage your switch any differently. Its useful even on
>>>>>>>>> devices that can't support flow based forwarding for statistics and
>>>>>>>>> setting port attributes like mtu, etc.
>>>>>>>>>
>>>>>>>>> .John
>>>>>>>>>
>>>>>>>> Probably bad form to respond to my own email but just to highlight how
>>>>>>>> subtle the distinction is (hopefully not to much repeat),
>>>>>>>>
>>>>>>>> Today in "legacy" mode each VF mac address is automatically added to
>>>>>>>> the fdb along with the PF mac address. If there is a miss in the table
>>>>>>>> (an unknown mac) the packet is sent to the PF but unless the PF is in
>>>>>>>> promisc mode the packet is dropped by the rx filter. I presume even
>>>>>>>> with the proposed model you would want to continue to enforce the
>>>>>>>> rx filter otherwise the instance you flip the mode you are open to
>>>>>>>> receive unwanted traffic. The promisc mode semantics have been in place
>>>>>>>> for a long time so certainly don't want to break that. Can we agree on
>>>>>>>> the promisc point? Also bridges/vswitch/etc already set promisc mode
>>>>>>>> once they attach to the netdevs.
>>>>>>>>
>>>>>>>> (assuming we agree on the promisc point?)
>>>>>>>> In your proposed model the only difference I can see is when the mode is
>>>>>>>> changed you don't want to add the VF mac address to the fdb table. How
>>>>>>>> about rather than make this part of the mode selection pick one way to
>>>>>>>> do this in all cases. Either add the VF mac addresses to the fdb or
>>>>>>>> do not do this. I have a preference for adding the VF mac addresses
>>>>>>>> because this is the current behavior. Then rename the devlink option
>>>>>>>> "VF reps" or something because that is what it is controlling.
>>>>>>>>
>>>>>>>> The last thing to argue about is if its a port attribute ala ethtool
>>>>>>>> or a device attribute ala devlink. But maybe we can agree on everything
>>>>>>>> up to this point?
>>>>>>>>
>>>>>>>> Thanks,
>>>>>>>> John
>>>>>>>>
>>>>>>> FWIW reviewing devlink and items I want to put there in the future I've
>>>>>>> decided it makes sense to keep it in devlink (sorry took me a day of
>>>>>>> emails to get here). If you can agree to the above and rename it
>>>>>>> something like,
>>>>>>>
>>>>>>> +enum devlink_eswitch_mode {
>>>>>>> +	DEVLINK_ESWITCH_MODE_NONE,
>>>>>>> +	DEVLINK_ESWITCH_MODE_LEGACY,
>>>>>>> +	DEVLINK_ESWITCH_MODE_CREATE_VF_NETDEVS,
>>>>>> That is certainly totally misleading name. The mode is not about
>>>>>> creating "VF netdevs".
>>>>>>
>>>>>> The VF representors are created but just as a side effect. The "offload"
>>>>>> mode or maybe better "switchdev" mode is creating representor netdevs for
>>>>>> VFs because they are needed in order to be able to configure ESwitch in
>>>>>> the same way we configure physical switches - putting netdevs into
>>>>>> bridge/bond/ovs/whatever. You see stats on the representors. Basicaly
>>>>>> they are the same as physical port representors on physical switch ASIC.
>>>>>
>>>>> May be we need 2 new modes
>>>>> - legacy+ mode which only creates VF netdevs and let the user configure and manage the switch via the standard bridge/tc/ip/ethtool interfaces
>>>>> - 'offload' or 'switchdev' mode that does more than just creating VF netdevs if it is not possible to configure the switch into this mode via standard interfaces.
>>>>
>>>> What?
>>>>
>>>> That what you described as "legacy+" as "let the user configure and
>>>> manage the switch via the standard bridge/tc/ip/ethtool interfaces" is
>>>> exactly the "offload/switchdev" mode.
>>>>
>>>> The second mode you described is something that I don't get what you are
>>>> talking about...
>>>>
>>>> Please forget about legacy. It's a mistake. Similar to SDKs :(
>>>> Let's work on getting the proper offload solution in.
>>>>
>>>
>>> I think the point here is switchdev is not needed to use bridge, tc,
>>> ip, and ethtool tools. By adding the VF representors we can continue
>>> using 'tc', 'bridge', etc. and it is much more interesting because
>>> we bring the VFs into the netdev world even without switchdev support
>>> this is nice. Adding switchdev of course gets you some extra goodies
>>> like l3 and l2 learning if your nic supports it but its not strictly
>>> required to see goodness from this patch. Without switchdev support
>>> you get stats (big win), basic port configuration with ip link cmds,
>>> tc and bridge fdb to name a few.
>> 
>> Why not to have 2 modes:
>> 
>> 1) lagacy - the current solution, blackbox eswitch, undefined behaviour
>> 2) switchdev - with representors, all features possible as on physical
>> switches, whitebox eswitch configured using standard tools?
>> 
>> I don't see *ANY* reason for a hybrid. That would only make things
>> already complicated much more complicated.
>> 
>>
>>>
>>> Also we can't completely forget about legacy though because we have
>>> infrastructure built around it and its unlikely we can switch entirely
>>> over in one shot. For example the firewall application may switch over
>>> to the new VF rep model while the libvirt VM manager continues to use
>>> the 'ip link set ... vf #' model. No reason to stop this from being
>>> supported its actually more work in the code to block it. We get it for
>>> free.
>> 
>> Let legacy be legacy, I have no problem with that. New drivers would be
>> encouraged to implement only new switchdev mode.
>> 
>
>Nope I disagree there is no reason to break existing userspace here just
>continue to support the handful of ip commands and bridge commands
>already supported. The code is already in the driver and supported.
>In general the kernel shouldn't break UAPI already in place.

Who is breaking existing userspace? I don't understand what breakage are
you are referring to :(


>
>> 
>>>
>>> I've come to the conclusion that we are just arguing over a name and
>>> a bit of perspective calling it "offload" mode is OK with me even
>>> though legacy mode did offloading as well just not as interesting of
>>> offloads. If the VF representors are the cause or effect is not all
>>> that important to me.
>> 
>> Why not call it just MODE_SWITCHDEV? I believe it describes it the best.
>> Everyone knows what that is about.
>> 
>
>This is fine but it doesn't require drivers actually register with
>switchdev here to get the goodness.

Switch id for ports, that is the only thing needed.


>
>> 
>>>
>>> If drivers populate the fdb table with known MACs is a side issue
>>> IMO (the thread Or and I got lost in) and doesn't need to hold up this
>>> patch.
>>>
>>> .John
>>>
>>>
>>>
>
