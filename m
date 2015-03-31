From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 11/18] switchdev: remove old
 netdev_switch_port_bridge_setlink
Date: Tue, 31 Mar 2015 23:52:45 +0200
Message-ID: <20150331215245.GA6515@nanopsycho.orion>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
 <1427704836-8776-12-git-send-email-sfeldma@gmail.com>
 <55194E63.5010100@cumulusnetworks.com>
 <CAE4R7bBWby3tDdzV+Hwvc_bzB3E-zNoHUQUX8OfF205Vyw-77g@mail.gmail.com>
 <E4CD12F19ABA0C4D8729E087A761DC35067FA7D3@ORSMSX101.amr.corp.intel.com>
 <CAE4R7bA4t-5P58jeK1NVAzM1fdk72o9UJRD8w+ByxKAtbp7b8A@mail.gmail.com>
 <E4CD12F19ABA0C4D8729E087A761DC35067FA9F0@ORSMSX101.amr.corp.intel.com>
 <20150331055235.GB1994@nanopsycho.orion>
 <E4CD12F19ABA0C4D8729E087A761DC35067FB3E2@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	roopa <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:34469 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbbCaVws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 17:52:48 -0400
Received: by wgbdm7 with SMTP id dm7so33979804wgb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 14:52:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067FB3E2@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 31, 2015 at 09:15:35PM CEST, ronen.arad@intel.com wrote:
>
>
>>-----Original Message-----
>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg] On
>>Behalf Of Jiri Pirko
>>Sent: Monday, March 30, 2015 10:53 PM
>>To: Arad, Ronen
>>Cc: Scott Feldman; Netdev; roopa; Guenter Roeck; Florian Fainelli
>>Subject: Re: [PATCH net-next 11/18] switchdev: remove old
>>netdev_switch_port_bridge_setlink
>>
>>Tue, Mar 31, 2015 at 02:08:34AM CEST, ronen.arad@intel.com wrote:
>>>
>>>
>>>>-----Original Message-----
>>>>From: Scott Feldman [mailto:sfeldma@gmail.com]
>>>>Sent: Monday, March 30, 2015 2:28 PM
>>>>To: Arad, Ronen
>>>>Cc: roopa; Netdev; Jir=C3=AD P=C3=ADrko; Guenter Roeck; Florian Fai=
nelli
>>>>Subject: Re: [PATCH net-next 11/18] switchdev: remove old
>>>>netdev_switch_port_bridge_setlink
>>>>
>>>>On Mon, Mar 30, 2015 at 1:46 PM, Arad, Ronen <ronen.arad@intel.com>=
 wrote:
>>>>>
>>>>>
>>>>>>-----Original Message-----
>>>>>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kern=
el.org]
>>On
>>>>>>Behalf Of Scott Feldman
>>>>>>Sent: Monday, March 30, 2015 1:20 PM
>>>>>>To: roopa
>>>>>>Cc: Netdev; Ji=C5=99=C3=AD P=C3=ADrko; Guenter Roeck; Florian Fai=
nelli
>>>>>>Subject: Re: [PATCH net-next 11/18] switchdev: remove old
>>>>>>netdev_switch_port_bridge_setlink
>>>>>>
>>>>>>On Mon, Mar 30, 2015 at 6:23 AM, roopa <roopa@cumulusnetworks.com=
> wrote:
>>>>>>> On 3/30/15, 1:40 AM, sfeldma@gmail.com wrote:
>>>>>>>>
>>>>>>>> From: Scott Feldman <sfeldma@gmail.com>
>>>>>>>>
>>>>>>>> New attr-based bridge_setlink can recurse lower devs and recov=
er on
>>err,
>>>>>>>> so
>>>>>>>> remove old wrapper.  Also, restore br_setlink back to original=
 and
>>don't
>>>>>>>> call
>>>>>>>> into SELF port driver.  rtnetlink.c:bridge_setlink already doe=
s a call
>>>>>>>> into
>>>>>>>> port driver for SELF.
>>>>>>>>
>>>>>>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>>>>>>
>>>>>>> removing this now requires every vlan add to be a two step proc=
ess, why
>>?
>>>>>>
>>>>>>No, that's not true.  You want to use
>>>>>>ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid in your port driver, and=
 then
>>>>>>using either vlan driver standalone or the bridge driver vlan sup=
port
>>>>>>will work.
>>>>>>
>>>>>>Try it.  Implement ndo_vlan_rx_add_vid in your port driver and ve=
rify
>>>>>>you get called to add VLAN to port with either:
>>>>>>
>>>>>>    bridge vlan add dev swp1 vid 10
>>>>>>
>>>>>>    -or-
>>>>>>
>>>>>>    vconfig add swp1 10
>>>>>>
>>>>>>Same for deleting a VLAN, either of these two commands call into =
the
>>>>>>port driver ndo_vlan_rx_kill_vid:
>>>>>>
>>>>>>    bridge vlan del dev swp1 vid 10
>>>>>>
>>>>>>    -or-
>>>>>>
>>>>>>    vconfig rem swp1 10
>>>>>>
>>>>>>
>>>>>>> bridge vlan add dev swp1 vid 10
>>>>>>> bridge vlan add dev swp1 vid 10 self
>>>>>>
>>>>>>Not necessary.  The first command is sufficient if using
>>>>>>ndo_vlan_rx_add_vid.
>>>>>
>>>>> This is not sufficient for VLAN filtering. Ndo_vlan_rx_add_vid do=
es not
>>>>> provide the vinfo flags PVID and UNTAGGED. Therefore it is not
>>>>> an adequate replacement for propagating setlink/dellink messages =
to the
>>>>> swithport driver or an alternative via swdev_attr.
>>>>
>>>>Glad you bring that point up.  I think these can get cast as port
>>>>attrs and set using swdev_attr.  This is something swdev attr shoul=
d
>>>>open up is allowing more settings to be pushed down to port driver.
>>>>I'll look into this one and include it with v2.
>>>
>>>It could be beneficial to build extensibility into swdev_attr.
>>>An experimenter attribute designed to carry arbitrary data could all=
ow
>>>for passing new attributes and implementation specific attributes
>>>without affecting any existing switchdev driver:
>>
>>Warning sign...
>>
>>I believe that we don't want this. It is very easy to add attribute f=
or
>>anything. Having this "universal attribuute" only allows wild things.=
=2E.
>>
>>Thanks.
>>
>>Jiri
>>
>Let's say a switch device has some behavior that is not common to all
>switch devices. Defining an explicit attribute might not be desirable
>in that case. For example let's say SOMEswitch device implements VLAN
>priority markdown using a table. It could be represented as a table of
>8 bytes. To support this feature, there is a need to allow a user-spac=
e
>tool to program such table in SOMEswitch device. What mechanisms are=20
>available for that?

If you want to expose feature X that's ok, just do it. I see no problem
in that. Please, just do not introduce kernel bypass. That simply won't
fly...


>This could be done via sysfs entries. However, I believe we're trying
>to make Netlink and iproute2 the protocol/tool for all switch device

It does not matter if universal attr is exposed via netlink or sysfs.
Either way, I believe it is unacceptable.

>configuration. Therefore, I think that a generic mechanism, integrated
>with existing switchdev supported tools would be best.=20
>Alternative approach would be for SOMEswitch driver to introduce its
>own generic netlink family and introduce SOMEswitch version of iproute=
2
>or similar tool to augment SOMEswitch HW configuration where (or as lo=
ng
>as) no common way to control such feature is available

This is definitelly unacceptable :/
