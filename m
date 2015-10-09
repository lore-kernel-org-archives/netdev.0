From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: switchdev and VLAN ranges
Date: Fri, 9 Oct 2015 19:30:51 -0400 (EDT)
Message-ID: <493168159.229458.1444433451493.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, stephen@networkplumber.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37833 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbbJIXaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 19:30:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I understand that specifying a VLAN range on the command line is nice
for the user, and it makes no big deal for software implementation.

However, AFAICT a VLAN range does not make sense at all for hardware
such as Ethernet switch chips. Am I wrong?

I would suggest to make switchdev directly answer to a bridge request
that the operation is not supported when the user asks for a VLAN range.

That way, we can simply use a single "vid" member in struct
switchdev_obj_port_vlan instead of "vid_begin" and "vid_end" and thus
avoid making drivers heavier with iteration loops on such range.

I have two concerns in mind:

a) if we imagine that drivers like Rocker allocate memory in the prepare
phase for each VID, preparing a range like 100-4000 would definitely not
be recommended.

b) imagine that you have two Linux bridges on a switch, one using the
hardware VLAN 100. If you request the VLAN range 99-101 for the other
bridge members, it is not possible for the driver to say "I can
accelerate VLAN 99 and 101, but not 100". It must return OPNOTSUPP for
the whole range.

That's why I think that avoiding VLAN range at the switchdev level would
be a good idea.

Thanks,
-v
