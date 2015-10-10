From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next] bridge: try switchdev op first in __vlan_vid_add/del
Date: Sat, 10 Oct 2015 11:16:39 -0700
Message-ID: <CAGVrzcZ=r03ZADDPu=z=CL7f_iwSqn+Du=F+i1j21quVka4JrQ@mail.gmail.com>
References: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
 <20151009224405.GA25393@ketchup.mtl.sfl> <CAE4R7bB-X_GekWgRTcdOJGa+JTwaxtHmttsFz0f19ae-t+d-Uw@mail.gmail.com>
 <20151010070123.GA1990@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35759 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbbJJSRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 14:17:19 -0400
Received: by iofl186 with SMTP id l186so38191998iof.2
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 11:17:19 -0700 (PDT)
In-Reply-To: <20151010070123.GA1990@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-10-10 0:01 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
> Sat, Oct 10, 2015 at 05:20:28AM CEST, sfeldma@gmail.com wrote:
>>On Fri, Oct 9, 2015 at 3:44 PM, Vivien Didelot
>><vivien.didelot@savoirfairelinux.com> wrote:
>>> Hi Jiri,
>>>
>>> On Oct. Friday 09 (41) 01:54 PM, Jiri Pirko wrote:
>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>
>>>> Some drivers need to implement both switchdev vlan ops and
>>>> vid_add/kill ndos. For that to work in bridge code, we need to try
>>>> switchdev op first when adding/deleting vlan id.
>>>
>>> Just curious, when would a driver need to have both operations?
>>
>>Ya, I was kind of curious of that myself. Is this because the driver
>>wants to support standalone VLANs using 802.1q module and vconfig, as
>>well as bridge vlans?  With the vlan support built into the bridge,
>>I've been working under the assumption that 802.1q module (and
>>vconfig) aren't needed, and vlans for a bridged and non-bridge port
>>can be managed using the "bridge" iproute2 cmd.
>
> Sure, but this is for standalone port device, without being bridged. In
> that case if you want to use vlan on top of that, you need these ndos.

Standalone VLAN configuration (that is, using vconfig/802.1q module)
is fairly limited, and only really makes sense, in its current
implementation for a host. By that, I mean, that we cannot configure
what is your default VLAN (the untagged one), and it does not matter
in the case of a host, because this is something that the other end:
the switch, has to have configured for you.

For netdevices from a switch device, I think we should really either
have the ability to use the same configuration flexibility as the
bridge VLAN filtering offers (setting PVID, untagged/default VLAN,
tagged), either outside of the bridge layer (which could be of limited
use), or just enforce the need of a bridge device to span these
specific ports of a switch.
-- 
Florian
