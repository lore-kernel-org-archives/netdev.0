From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 06/14] rocker: introduce worlds infrastructure
Date: Wed, 7 Oct 2015 19:51:34 +0200
Message-ID: <20151007175134.GJ2152@nanopsycho.orion>
References: <1444117913-10386-1-git-send-email-jiri@resnulli.us>
 <1444117913-10386-7-git-send-email-jiri@resnulli.us>
 <CAE4R7bCdAQxLo3tKbXAqyGa_F3PhUTUkqrM5jTkYqcJJbCDmog@mail.gmail.com>
 <5613F482.2010200@gmail.com>
 <CAE4R7bAhc1HyrCxQfbfXUhQgME=UfjdVtF5PAyxy1Oe5g5EoTw@mail.gmail.com>
 <56143C50.2050604@gmail.com>
 <CAE4R7bBzidcLVgP7TybtHDHhgmQv1FAY9toyDDmSa8Y5bhg-zw@mail.gmail.com>
 <20151007061409.GB2152@nanopsycho.orion>
 <CAE4R7bAFBBdhoAVx4s0Ljc-Kcpvn8F-bHG+N6-1oxntnearWZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35515 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902AbbJGRvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 13:51:37 -0400
Received: by wicge5 with SMTP id ge5so224204403wic.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 10:51:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAFBBdhoAVx4s0Ljc-Kcpvn8F-bHG+N6-1oxntnearWZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 07, 2015 at 07:32:45PM CEST, sfeldma@gmail.com wrote:
>On Tue, Oct 6, 2015 at 11:14 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Oct 07, 2015 at 03:50:08AM CEST, sfeldma@gmail.com wrote:
>>
>> <snip>
>>
>>>
>>>> Also I wonder how this works when a pkt ingresses a port in mode A and
>>>> egresses a port in mode B? What fib/fdb tables does it cross when this
>>>> happens? It seems easier to just have two switch devices not a
>>>> hybrid. If this per port implementation maps to some hardware that
>>>> would be really interesting though.
>>>
>>>In retrospect, I regret adding the port mode feature to rocker.  I
>>>like the world idea, so we can have a device with different
>>>pipeline/resources, but we should have locked all ports on a switch to
>>>one mode, or even as you hinted at earlier, use a unique sub-device ID
>>>for a switch with all ports in a particular mode.  If you want to
>>>ports with different worlds, just instantiate a switch in each world.
>>>Instantiating new devices is easy.
>>>
>>>But, now Jiri has locked on to the dynamic port mode idea with pit
>>>bull zeal, to the point of being able to switch a port mode at any
>>>time from one mode to another from the host.  I just don't see that as
>>>a real-world use-case.  Life is too short and we need to be focusing
>>>on switchdev features, not refactoring or adding cool but useless
>>>features.
>>
>> Can can still change this if you want. We can make
>> ROCKER_TLV_CMD_PORT_SETTINGS_MODE read-only in hw (As it is in fact now
>> as we have only one world).
>>
>> Then we add another property:
>> static Property rocker_properties[] = {
>>             DEFINE_PROP_STRING("name", Rocker, name),
>>             DEFINE_PROP_STRING("world", Rocker, world),
>>                 ....
>>
>> and we use this value in pci_rocker_init instead of r->world_dflt
>>
>> Looks straightforward.
>
>Yes, perfect, I totally on-board with that change.  This puts all
>ports on the device in the same mode.  I you want ports in a different
>mode, instantiate another switch.
>
>Mixing port modes on a switch, either statically or dynamically, would
>have created another problem.  Switchdev uses the switch_id for each
>port to know when ports belong to the same switch, same switching
>domain, if you will.  Mixing port modes within a switch breaks this.
>For example, the check we added to avoid double forwarding of pkts by
>the bridge and the device depends on ports on the switch having the
>same switch_id.

Ok. Will fix this in qemu as well.
