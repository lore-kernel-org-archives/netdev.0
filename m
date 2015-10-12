From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next] bridge: try switchdev op first in __vlan_vid_add/del
Date: Sun, 11 Oct 2015 21:20:44 -0700
Message-ID: <CAE4R7bAVQ5PN4d8fKbF8H96CtSQA9qBBjE_JVSPPek+5+K-cww@mail.gmail.com>
References: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
 <20151009224405.GA25393@ketchup.mtl.sfl> <CAE4R7bB-X_GekWgRTcdOJGa+JTwaxtHmttsFz0f19ae-t+d-Uw@mail.gmail.com>
 <20151010160354.GB14572@ketchup>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35405 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbbJLEVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 00:21:05 -0400
Received: by obbzf10 with SMTP id zf10so98843824obb.2
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 21:21:04 -0700 (PDT)
In-Reply-To: <20151010160354.GB14572@ketchup>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 10, 2015 at 9:03 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> On Oct. Friday 09 (41) 08:20 PM, Scott Feldman wrote:
>> On Fri, Oct 9, 2015 at 3:44 PM, Vivien Didelot
>> <vivien.didelot@savoirfairelinux.com> wrote:
>> > Hi Jiri,
>> >
>> > On Oct. Friday 09 (41) 01:54 PM, Jiri Pirko wrote:
>> >> From: Jiri Pirko <jiri@mellanox.com>
>> >>
>> >> Some drivers need to implement both switchdev vlan ops and
>> >> vid_add/kill ndos. For that to work in bridge code, we need to try
>> >> switchdev op first when adding/deleting vlan id.
>> >
>> > Just curious, when would a driver need to have both operations?
>>
>> Ya, I was kind of curious of that myself. Is this because the driver
>> wants to support standalone VLANs using 802.1q module and vconfig, as
>> well as bridge vlans?  With the vlan support built into the bridge,
>> I've been working under the assumption that 802.1q module (and
>> vconfig) aren't needed, and vlans for a bridged and non-bridge port
>> can be managed using the "bridge" iproute2 cmd.
>>
>> > I kinda have the same question regarding ndo_fdb_{add,del} and the
>> > bridge_{get,set}link equivalent, which is a bit confusing to me.
>>
>> I had to look back at my commit 7f109539 to remind myself about the
>> vid_add/kill ndos and bridge_{get,set}link usage.   Maybe that
>> write-up helps?  I'm not following you on the ndo_fdb_add/del part of
>> your question.
>
> Sorry I wasn't clear. What is confusing to me for FDB ops is that we
> define net_device_ops like:
>
>         .ndo_fdb_add            = switchdev_port_fdb_add,
>         .ndo_fdb_del            = switchdev_port_fdb_del,
>         .ndo_fdb_dump           = switchdev_port_fdb_dump,
>
> But if I'm not mistaken, "bridge fdb" commands use the
> .ndo_bridge_{get,set,del}link ops, isn't it?

No, the "bridge fdb" cmds use the .ndo_fdb_xxx ops.
