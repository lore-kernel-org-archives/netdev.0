From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] bridge: try switchdev op first in
 __vlan_vid_add/del
Date: Sat, 10 Oct 2015 09:01:23 +0200
Message-ID: <20151010070123.GA1990@nanopsycho.orion>
References: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
 <20151009224405.GA25393@ketchup.mtl.sfl>
 <CAE4R7bB-X_GekWgRTcdOJGa+JTwaxtHmttsFz0f19ae-t+d-Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35490 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbbJJHB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 03:01:26 -0400
Received: by wicge5 with SMTP id ge5so93974553wic.0
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 00:01:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bB-X_GekWgRTcdOJGa+JTwaxtHmttsFz0f19ae-t+d-Uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 10, 2015 at 05:20:28AM CEST, sfeldma@gmail.com wrote:
>On Fri, Oct 9, 2015 at 3:44 PM, Vivien Didelot
><vivien.didelot@savoirfairelinux.com> wrote:
>> Hi Jiri,
>>
>> On Oct. Friday 09 (41) 01:54 PM, Jiri Pirko wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> Some drivers need to implement both switchdev vlan ops and
>>> vid_add/kill ndos. For that to work in bridge code, we need to try
>>> switchdev op first when adding/deleting vlan id.
>>
>> Just curious, when would a driver need to have both operations?
>
>Ya, I was kind of curious of that myself. Is this because the driver
>wants to support standalone VLANs using 802.1q module and vconfig, as
>well as bridge vlans?  With the vlan support built into the bridge,
>I've been working under the assumption that 802.1q module (and
>vconfig) aren't needed, and vlans for a bridged and non-bridge port
>can be managed using the "bridge" iproute2 cmd.

Sure, but this is for standalone port device, without being bridged. In
that case if you want to use vlan on top of that, you need these ndos.
