From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 11/18] switchdev: remove old netdev_switch_port_bridge_setlink
Date: Tue, 31 Mar 2015 19:38:09 -0700
Message-ID: <CAE4R7bCeRxP2Kg_4jg4v6m6S+3NFpMcxO4vC-WeDG48GPkCtuw@mail.gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
	<1427704836-8776-12-git-send-email-sfeldma@gmail.com>
	<55194E63.5010100@cumulusnetworks.com>
	<CAE4R7bBWby3tDdzV+Hwvc_bzB3E-zNoHUQUX8OfF205Vyw-77g@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC35067FA7D3@ORSMSX101.amr.corp.intel.com>
	<CAE4R7bA4t-5P58jeK1NVAzM1fdk72o9UJRD8w+ByxKAtbp7b8A@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC35067FA9F0@ORSMSX101.amr.corp.intel.com>
	<20150331055235.GB1994@nanopsycho.orion>
	<E4CD12F19ABA0C4D8729E087A761DC35067FB3E2@ORSMSX101.amr.corp.intel.com>
	<20150331215245.GA6515@nanopsycho.orion>
	<E4CD12F19ABA0C4D8729E087A761DC35067FB536@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	roopa <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:34854 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbbDACiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 22:38:10 -0400
Received: by qcbii10 with SMTP id ii10so8008591qcb.2
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 19:38:10 -0700 (PDT)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067FB536@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2015 at 4:32 PM, Arad, Ronen <ronen.arad@intel.com> wrote:
>
>
>>-----Original Message-----
>>From: Jiri Pirko [mailto:jiri@resnulli.us]
>>Sent: Tuesday, March 31, 2015 2:53 PM
>>To: Arad, Ronen
>>Cc: Scott Feldman; Netdev; roopa; Guenter Roeck; Florian Fainelli
>>Subject: Re: [PATCH net-next 11/18] switchdev: remove old
>>netdev_switch_port_bridge_setlink
>>
>>Tue, Mar 31, 2015 at 09:15:35PM CEST, ronen.arad@intel.com wrote:
>>>
>>>
>>>>-----Original Message-----
>>>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>>>>Behalf Of Jiri Pirko
>>>>Sent: Monday, March 30, 2015 10:53 PM
>>>>To: Arad, Ronen
>>>>Cc: Scott Feldman; Netdev; roopa; Guenter Roeck; Florian Fainelli
>>>>Subject: Re: [PATCH net-next 11/18] switchdev: remove old
>>>>netdev_switch_port_bridge_setlink
>>>>
>>>>Tue, Mar 31, 2015 at 02:08:34AM CEST, ronen.arad@intel.com wrote:
>>>>>
> [cut]
>>>>>
>>>>>It could be beneficial to build extensibility into swdev_attr.
>>>>>An experimenter attribute designed to carry arbitrary data could allow
>>>>>for passing new attributes and implementation specific attributes
>>>>>without affecting any existing switchdev driver:
>>>>
>>>>Warning sign...
>>>>
>>>>I believe that we don't want this. It is very easy to add attribute for
>>>>anything. Having this "universal attribuute" only allows wild things...
>>>>
>>>>Thanks.
>>>>
>>>>Jiri
>>>>
>>>Let's say a switch device has some behavior that is not common to all
>>>switch devices. Defining an explicit attribute might not be desirable
>>>in that case. For example let's say SOMEswitch device implements VLAN
>>>priority markdown using a table. It could be represented as a table of
>>>8 bytes. To support this feature, there is a need to allow a user-space
>>>tool to program such table in SOMEswitch device. What mechanisms are
>>>available for that?
>>
>>If you want to expose feature X that's ok, just do it. I see no problem
>>in that. Please, just do not introduce kernel bypass.
>
> This is not a kernel bypass as long as the target device is an in-tree
> device driver open for the community scrutiny.
>
>  That simply won't
>>fly...
>
> Let's say vendor X wants to expose features X1, X2, ...Xm,
> vendor Y wants to expose features Y1, Y2, ...Yn, etc.
> How this would be visible to the users via iproute2?
> We'll need keywords Kx1..Kxm, Ky1..Kn, etc. There is scalability issue here.
> The user has to figure out the keyword Kxj goes with feature Xj etc.
> There must be a better way.
>
> What I have in mind is a way for switchdevX driver to define the its options
> and the keywords that the user could use to control them in a generic way.
> The kernel will provide the mechanism to export that to user space such that
> A tool like iproute2 could present user-friendly interface which is context
> aware.
>
> It is important to allow for a generic interface that will not require a new
> patch to the user-space tool or to the kernel net core (or switchdev) infrastructure, whenever any such new feature is being exposed.
> Only the switchdev driver which exposes a new feature need a patch.
>
> The kernel could have sufficient information about the information that
> switchdevX is expecting such that it could validate size and type and could
> reject information that is not supported by the device.
>
> This is very similar to the options interface the team driver exposes.
> Team driver provides the mechanism for user-space to configure options in the
> kernel. Team driver does not understand or interpret the options that are
> intended for team modes. It only provides the mechanism to communicate them
> over generic netlink and process them in the kernel and user-space.
> Those options do not show up in any header file. You don't need a new kernel
> version to introduce a new team option for a new or existing team mode.
> All you need is to register the option (identified by a string) with team
> driver and set/get it from the teamd or any other user-space tool over
> generic netlink.
> The team protocol is stable and does not require changes for this level of
> extensibility.
>
> The same level of extensibility is needed for switchdev port or device
> attributes.

It sounds like vendor extensions need to be supported someway,
someday.  Maybe let's table vendor extensions for the time being and
continue our focus on shared infrastructure: the things we know are
common for all vendors.  We still have a lot of work just getting the
common bits working.  Then we can take additional features one at a
time and see if they're shared or vendor-specific.  In the meantime,
there are always back doors such as genl for vendor to use; there is
nothing preventing that.

-scott
