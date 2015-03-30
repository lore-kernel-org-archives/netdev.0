From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 11/18] switchdev: remove old netdev_switch_port_bridge_setlink
Date: Mon, 30 Mar 2015 14:27:48 -0700
Message-ID: <CAE4R7bA4t-5P58jeK1NVAzM1fdk72o9UJRD8w+ByxKAtbp7b8A@mail.gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
	<1427704836-8776-12-git-send-email-sfeldma@gmail.com>
	<55194E63.5010100@cumulusnetworks.com>
	<CAE4R7bBWby3tDdzV+Hwvc_bzB3E-zNoHUQUX8OfF205Vyw-77g@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC35067FA7D3@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roopa <roopa@cumulusnetworks.com>, Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?Smlyw60gUMOtcmtv?= <jiri@resnulli.us>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:34941 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbbC3V1t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 17:27:49 -0400
Received: by qgh3 with SMTP id 3so185838254qgh.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 14:27:48 -0700 (PDT)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067FA7D3@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 1:46 PM, Arad, Ronen <ronen.arad@intel.com> wro=
te:
>
>
>>-----Original Message-----
>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg] On
>>Behalf Of Scott Feldman
>>Sent: Monday, March 30, 2015 1:20 PM
>>To: roopa
>>Cc: Netdev; Ji=C5=99=C3=AD P=C3=ADrko; Guenter Roeck; Florian Fainell=
i
>>Subject: Re: [PATCH net-next 11/18] switchdev: remove old
>>netdev_switch_port_bridge_setlink
>>
>>On Mon, Mar 30, 2015 at 6:23 AM, roopa <roopa@cumulusnetworks.com> wr=
ote:
>>> On 3/30/15, 1:40 AM, sfeldma@gmail.com wrote:
>>>>
>>>> From: Scott Feldman <sfeldma@gmail.com>
>>>>
>>>> New attr-based bridge_setlink can recurse lower devs and recover o=
n err,
>>>> so
>>>> remove old wrapper.  Also, restore br_setlink back to original and=
 don't
>>>> call
>>>> into SELF port driver.  rtnetlink.c:bridge_setlink already does a =
call
>>>> into
>>>> port driver for SELF.
>>>>
>>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>>
>>> removing this now requires every vlan add to be a two step process,=
 why ?
>>
>>No, that's not true.  You want to use
>>ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid in your port driver, and the=
n
>>using either vlan driver standalone or the bridge driver vlan support
>>will work.
>>
>>Try it.  Implement ndo_vlan_rx_add_vid in your port driver and verify
>>you get called to add VLAN to port with either:
>>
>>    bridge vlan add dev swp1 vid 10
>>
>>    -or-
>>
>>    vconfig add swp1 10
>>
>>Same for deleting a VLAN, either of these two commands call into the
>>port driver ndo_vlan_rx_kill_vid:
>>
>>    bridge vlan del dev swp1 vid 10
>>
>>    -or-
>>
>>    vconfig rem swp1 10
>>
>>
>>> bridge vlan add dev swp1 vid 10
>>> bridge vlan add dev swp1 vid 10 self
>>
>>Not necessary.  The first command is sufficient if using
>>ndo_vlan_rx_add_vid.
>
> This is not sufficient for VLAN filtering. Ndo_vlan_rx_add_vid does n=
ot
> provide the vinfo flags PVID and UNTAGGED. Therefore it is not
> an adequate replacement for propagating setlink/dellink messages to t=
he
> swithport driver or an alternative via swdev_attr.

Glad you bring that point up.  I think these can get cast as port
attrs and set using swdev_attr.  This is something swdev attr should
open up is allowing more settings to be pushed down to port driver.
I'll look into this one and include it with v2.
