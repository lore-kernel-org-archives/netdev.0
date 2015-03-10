From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Tue, 10 Mar 2015 09:28:17 +0100
Message-ID: <20150310082817.GC1995@nanopsycho.orion>
References: <CAE4R7bAaLxCebc7cuYB9NQ_Duo8a6LvxWDwWOD9Wn8ROWjvDGw@mail.gmail.com>
 <54FC5A60.7000800@cumulusnetworks.com>
 <CAE4R7bDrhnK_a9dvyMqSJkGgod6AM=HDE6CAKkG_RnjuDxB2-Q@mail.gmail.com>
 <CAJieiUhHdXOZjWkb4s_GviLwzq5Gct-1o8xv8b-JeM46S4e-dg@mail.gmail.com>
 <20150309064043.GB2053@nanopsycho.orion>
 <E4CD12F19ABA0C4D8729E087A761DC35067E6A8D@ORSMSX101.amr.corp.intel.com>
 <20150309160754.GA2169@nanopsycho.lan>
 <E4CD12F19ABA0C4D8729E087A761DC35067E6EF0@ORSMSX101.amr.corp.intel.com>
 <20150310063926.GA1995@nanopsycho.orion>
 <E4CD12F19ABA0C4D8729E087A761DC35067E7016@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:46790 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbbCJI2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 04:28:21 -0400
Received: by wiwh11 with SMTP id h11so802624wiw.5
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 01:28:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067E7016@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 10, 2015 at 09:02:00AM CET, ronen.arad@intel.com wrote:
>
>
>>-----Original Message-----
>>From: Jiri Pirko [mailto:jiri@resnulli.us]
>>Sent: Tuesday, March 10, 2015 6:39 AM
>>To: Arad, Ronen
>>Cc: Netdev; Roopa Prabhu; Scott Feldman; David S. Miller
>>Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
>>setlink handler
>>
>>Tue, Mar 10, 2015 at 01:51:51AM CET, ronen.arad@intel.com wrote:
>>>
>>>
>>>>-----Original Message-----
>>>>From: Jiri Pirko [mailto:jiri@resnulli.us]
>>>>Sent: Monday, March 09, 2015 4:08 PM
>>>>To: Arad, Ronen
>>>>Cc: Roopa Prabhu; Scott Feldman; Netdev; David S. Miller
>>>>Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
>>>>setlink handler
>>>>
>>>>Mon, Mar 09, 2015 at 04:59:13PM CET, ronen.arad@intel.com wrote:
>>>>>
>>>>>
>>>>>>-----Original Message-----
>>>>>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>>On
>>>>>>Behalf Of Jiri Pirko
>>>>>>Sent: Monday, March 09, 2015 6:41 AM
>>>>>>To: Roopa Prabhu
>>>>>>Cc: Scott Feldman; Netdev; David S. Miller
>>>>>>Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in
>>bridge
>>>>>>setlink handler
>>>>>>
>>>>>>Mon, Mar 09, 2015 at 01:12:47AM CET, roopa@cumulusnetworks.com wrote:
>>>>>>>On Sun, Mar 8, 2015 at 4:17 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>>>>>>>
>>>>>>>> On Sun, Mar 8, 2015 at 7:19 AM, roopa <roopa@cumulusnetworks.com>
>>wrote:
>>>>>>>> > On 3/6/15, 1:52 AM, Scott Feldman wrote:
>>>>>>>>
>>>[cut]
>>>>>>
>>>>>It would be nice to have switch driver implementation that could work
>>>>>Consistently with and without the bridge driver. I expect use case where a
>>>>bridge is only used when L3 is needed or to leverage L2 protocols that are
>>>>implemented by the bridge driver (e.g. STP, IGMP snooping).
>>>>>
>>>>>If my driver can process setlink requests using SELF flag today, I'd like
>>it
>>>>>to work the same when setlink is propagated down from a bridge master or
>>>>>from a team/bond master.
>>>>
>>>>I just want to note that the name of the op is "ndo_bridge_setlink" and
>>>>it is specific for in-bridge use. Using it for team/bond seems very
>>>>wrong to me.
>>>>
>>>
>>>This propagation from master to its slaves is in a recently applied patch.
>>>Are you suggesting reverting the patch which added
>>>ndo_dflt_netdev_switch_port_bridge_setlink function which is set as the
>>>ndo_bridge_setlink of both team and bond drivers?
>>
>>I'm not suggesting such thing. Proparation is correct. Origination is
>>not. That was my point.
>>
>I'd like to make sure I understand your position. If only propagation is
>correct, it would mean that a bridge device is always required for VLAN
>filtering configuration.

Not accurate. Setting this via ndo_bridge_setlink should be done only in
case netdev is a bridge port. There are other ndos to do this when vlan
dev in on top (ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid)


>This also mean that targeting "bridge vlan add vid VLAN-ID dev DEVNAME self"
>to DEVNAME of a switch port type or team/bond is incorrect.

Definitelly. PF_BRIDGE should be used only for bridge and its ports.
(Leaving aside the fact that PF_BRIDGE should have never been
introduced, should be replaced and let to rot)


>If this position is accepted, it would be best to enforce it, possibly in
>rtnl_bridge_setlink().
>My recollection is that others asked to preserve use-cases where SELF flag
>is used for targeting port devices directly without using a bridge device.

I know it is possible, and it is incorrect and hacky. But it is part of
user api :/ I think we should not abuse this more in the future and
rather make the api correct and use that.


>>>
>>>Would renaming this NDO to "ndo_master_setlink" address your concern?
>>>It could clarify that this ndo deals with master devices and is not limited
>>>To just bridge driver.
>>
>>Renaming ndo is not enough.... You would have to do much more.
>>
>>>
>>>My interest here is the VLAN filtering policy which is provisioned using the
>>>IFLA_AF_SPEC nested attribute of RTM_SETLINK command in PF_BRIDGE family.
>>>VLAN policy is something that is common to Ethernet ports (physical or
>>logical),
>>>VLAN-aware bridge, or team/bond ports.
>>>
>>>It is a reasonable expectation of users to use the team/bond as target for
>>>any configuration that has to be mirrored to all of their enslaved ports.
>>>
>>>[cut]
>>>>>>--
>>>>>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>>>>the body of a message to majordomo@vger.kernel.org
>>>>>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
