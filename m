From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 13/16] i40e: Fix i40e_ndo_set_vf_spoofchk
Date: Mon, 23 Feb 2015 23:52:04 +0200
Message-ID: <CAJ3xEMi7w+gp5QohzK3ByBENoOKWiQi+5761Lo-yDzgU__+Xow@mail.gmail.com>
References: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1424661944-1779-14-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJ3xEMgf1ue3Byt3n1+LYFFKED8fq3RXJhqihTY=X6cww_MQkg@mail.gmail.com>
	<C5551D9AAB213A418B7FD5E4A6F30A078926426F@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:43138 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbbBWVwF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 16:52:05 -0500
Received: by mail-ob0-f173.google.com with SMTP id uy5so39624719obc.4
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 13:52:04 -0800 (PST)
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A078926426F@ORSMSX108.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2015 at 7:31 PM, Rose, Gregory V
<gregory.v.rose@intel.com> wrote:
>> From: Or Gerlitz [mailto:gerlitz.or@gmail.com]

>> > The netdev op that allows the operator to turn MAC/VLAN spoof checking
>> > on and off did not include the flag for VLAN spoof checking.  This
>> > patch fixes that problem.

>> If we're on VST mode, the VF isn't aware their traffic is tagged with
>> vlan-id Y and if they try to send with vlan-id X I assume you are forcing
>> it to be Y, right?

> No, it is dropped and a malicious driver event is registered to the PF driver.

Why are you treating the VF as malicious if under VST mode no one told
them what vlans are allowed for them to use? or your PF driver
communicates the vlan mode (VST/VGT) to the VF?

>> If we're on VGT mode, what spoof check you can do? we don't have a model
>> for allowed vlans, did I miss something?

> This only applies in instances where the administrator has not set a VLAN id for the VF via the 'ip' utility.  In that case, our rule is to allow the VF driver to set its own VLAN filters if it so wishes.  This is a long standing rule for Intel VF drivers.

makes sense

> So, with VLAN spoof checking turned on [...]

what exactly you mean by "VLAN spoof checking turned on" and how the
admin tells the PF to go into this mode?
