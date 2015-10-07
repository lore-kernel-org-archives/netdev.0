From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v3 06/14] rocker: introduce worlds infrastructure
Date: Wed, 07 Oct 2015 08:46:13 -0700
Message-ID: <56153E45.2080807@gmail.com>
References: <1444117913-10386-1-git-send-email-jiri@resnulli.us> <1444117913-10386-7-git-send-email-jiri@resnulli.us> <CAE4R7bCdAQxLo3tKbXAqyGa_F3PhUTUkqrM5jTkYqcJJbCDmog@mail.gmail.com> <5613F482.2010200@gmail.com> <CAE4R7bAhc1HyrCxQfbfXUhQgME=UfjdVtF5PAyxy1Oe5g5EoTw@mail.gmail.com> <56143C50.2050604@gmail.com> <CAE4R7bBzidcLVgP7TybtHDHhgmQv1FAY9toyDDmSa8Y5bhg-zw@mail.gmail.com> <20151007061409.GB2152@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35194 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754410AbbJGPq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 11:46:29 -0400
Received: by pacfv12 with SMTP id fv12so25354202pac.2
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 08:46:29 -0700 (PDT)
In-Reply-To: <20151007061409.GB2152@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-10-06 11:14 PM, Jiri Pirko wrote:
> Wed, Oct 07, 2015 at 03:50:08AM CEST, sfeldma@gmail.com wrote:
> 
> <snip>
> 
>>
>>> Also I wonder how this works when a pkt ingresses a port in mode A and
>>> egresses a port in mode B? What fib/fdb tables does it cross when this
>>> happens? It seems easier to just have two switch devices not a
>>> hybrid. If this per port implementation maps to some hardware that
>>> would be really interesting though.
>>
>> In retrospect, I regret adding the port mode feature to rocker.  I
>> like the world idea, so we can have a device with different
>> pipeline/resources, but we should have locked all ports on a switch to
>> one mode, or even as you hinted at earlier, use a unique sub-device ID
>> for a switch with all ports in a particular mode.  If you want to
>> ports with different worlds, just instantiate a switch in each world.
>> Instantiating new devices is easy.
>>
>> But, now Jiri has locked on to the dynamic port mode idea with pit
>> bull zeal, to the point of being able to switch a port mode at any
>> time from one mode to another from the host.  I just don't see that as
>> a real-world use-case.  Life is too short and we need to be focusing
>> on switchdev features, not refactoring or adding cool but useless
>> features.
> 
> Can can still change this if you want. We can make
> ROCKER_TLV_CMD_PORT_SETTINGS_MODE read-only in hw (As it is in fact now
> as we have only one world).
> 
> Then we add another property:
> static Property rocker_properties[] = {
> 	    DEFINE_PROP_STRING("name", Rocker, name),
> 	    DEFINE_PROP_STRING("world", Rocker, world),
> 		....
> 
> and we use this value in pci_rocker_init instead of r->world_dflt
> 
> Looks straightforward.
> 
> 

I think that would map better to something real hardware would do. In
this case it looks like you reprogrammed the device or pushed a
microcode update at it and loaded a new world. Reporting the string
in ethtool or something might be a nice touch as well.

Just a couple editorial comments, hopefully I'm not sounding critical
of the multiworld stuff I really want to use this! And two we have
devices that can change characteristics at runtime such as the parser,
table type/sizes/layouts, even supported actions so I do want the
sort of dynamic knobs originally proposed just not as strings. But I
think that is our "worlds" vs "profiles" debate.

Thanks!
John
