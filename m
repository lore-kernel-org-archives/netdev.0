From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 13/16] i40e: Fix i40e_ndo_set_vf_spoofchk
Date: Tue, 24 Feb 2015 11:19:58 +0200
Message-ID: <CAJ3xEMgY_w-7ACmyHBKwf_p5MhiNPaD+pfidBUQy0+Y8m7TRhA@mail.gmail.com>
References: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1424661944-1779-14-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJ3xEMgf1ue3Byt3n1+LYFFKED8fq3RXJhqihTY=X6cww_MQkg@mail.gmail.com>
	<C5551D9AAB213A418B7FD5E4A6F30A078926426F@ORSMSX108.amr.corp.intel.com>
	<CAJ3xEMi7w+gp5QohzK3ByBENoOKWiQi+5761Lo-yDzgU__+Xow@mail.gmail.com>
	<C5551D9AAB213A418B7FD5E4A6F30A0789265663@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Rony Efraim <ronye@mellanox.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:39479 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbbBXJT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 04:19:59 -0500
Received: by mail-ob0-f177.google.com with SMTP id wp18so40391744obc.8
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 01:19:58 -0800 (PST)
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0789265663@ORSMSX108.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 12:00 AM, Rose, Gregory V
<gregory.v.rose@intel.com> wrote:
>> -----Original Message-----
>> From: Or Gerlitz [mailto:gerlitz.or@gmail.com]
>> Sent: Monday, February 23, 2015 1:52 PM
>> To: Rose, Gregory V
>> Cc: Kirsher, Jeffrey T; David Miller; Linux Netdev List;
>> nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com
>> Subject: Re: [net-next 13/16] i40e: Fix i40e_ndo_set_vf_spoofchk
>>
>> On Mon, Feb 23, 2015 at 7:31 PM, Rose, Gregory V
>> <gregory.v.rose@intel.com> wrote:
>> >> From: Or Gerlitz [mailto:gerlitz.or@gmail.com]
>>
>> >> > The netdev op that allows the operator to turn MAC/VLAN spoof
>> >> > checking on and off did not include the flag for VLAN spoof
>> >> > checking.  This patch fixes that problem.
>>
>> >> If we're on VST mode, the VF isn't aware their traffic is tagged with
>> >> vlan-id Y and if they try to send with vlan-id X I assume you are
>> >> forcing it to be Y, right?
>>
>> > No, it is dropped and a malicious driver event is registered to the PF
>> driver.
>>
>> Why are you treating the VF as malicious if under VST mode no one told
>> them what vlans are allowed for them to use?
>
> I'm not sure what you mean by VST/VGT modes.

Oops, sorry, these two terms were borrowed from the ESX jargon, and I
was under the maybe misconception they are part of the Linux speak
too, anyway

To me you're talking about a port VLAN model where the HW
inserts/removes the VLAN tag while the VF driver knows nothing about
it

yes, this == VST (Virtual Switch Tagging), which is more common I
believe, called "access mode" in physical switches

vs. the more standard model where the driver is allowed to
insert/remove VLAN tags under its own control (still with HW assist).

yes, this is VGT (Virtual Guest Tagging), called "trunk mode" in
physical switches


> Is that correct?  I think we need to make sure our terms and definitions match.

we were aligned but used different terms.

>  or your PF driver
>> communicates the vlan mode (VST/VGT) to the VF?
>
> The PF driver does not need to communicate the VLAN mode to the VF.

OK, good.


>> >> If we're on VGT mode, what spoof check you can do? we don't have a
>> >> model for allowed vlans, did I miss something?
>>
>> > This only applies in instances where the administrator has not set a
>> VLAN id for the VF via the 'ip' utility.  In that case, our rule is to
>> allow the VF driver to set its own VLAN filters if it so wishes.  This is
>> a long standing rule for Intel VF drivers.
>>
>> makes sense
>>
>> > So, with VLAN spoof checking turned on [...]

>> what exactly you mean by "VLAN spoof checking turned on" and how the admin
>> tells the PF to go into this mode?

> #ip link set <pf interface> vf <n> spoofchk <on/off>

> With spoof checking off then the VF can send/receive on any VLAN it wants.  With spoof checking on the VLAN filter must exist in the HW filtering before the VF can send/receive on that VLAN.

So we agree that the only thing the VF knows is the MAC which was
provisioned to them by the admin through the PF, so in that respect, I
am still not clear what is the criteria for your PF driver to decide
they are spoofing a vlan-id?!

Or.


>
> - Greg
