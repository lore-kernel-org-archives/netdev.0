From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 00/14] rocker: add support for multiple worlds
Date: Mon, 05 Oct 2015 10:56:26 -0700
Message-ID: <5612B9CA.2010101@gmail.com>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us> <56129A32.1010201@gmail.com> <20151005163012.GO2278@nanopsycho.orion> <5612AC1E.1050504@gmail.com> <20151005173951.GT2278@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com,
	idosch@mellanox.com, eladr@mellanox.com, tgraf@suug.ch,
	ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34739 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbJER4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:56:42 -0400
Received: by padhy16 with SMTP id hy16so43035717pad.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:56:41 -0700 (PDT)
In-Reply-To: <20151005173951.GT2278@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>> I think your underestimating the flexibility of hardware. And
>> completely missing the hardware that is based on FPGAs and/or cell
>> architectures. This hardware is available today and could support
>> topology changes like this. But even less exotic hardware can/will
>> support parser updates which makes the device behave differently.
> 
> Sure, I'm just trying to explain that woulds and your "profiles" are
> something completely different. I feel like we are running in circles.
> 

Must be going in circles because I don't see the difference.

> 
>>
>> Other hardware can reconfigure the topology within some constraints,
>> the fm10k device supports this model. An extreme example would put
>> an ebpf interpreter in a fpga on the nic and expose it via a driver.
>>
>> If its just for rocker purposes I'm not really excited about adding
>> it to the kernel to support a qemu device. If we allow it for one
> 
> What exactly are you against? Multi-world support as it is of the
> userspace iface to change worlds? If the second, I understand, kind of.
> 

Just the userspace interface. I have hardware that can support
multiple worlds (although I'm fuzzy what you mean by worlds) today and
want to expose that as well. I guess my main objection is I wanted to
get away from out of band firmware/microcode updates and this doesn't
really look much better to me as I currently understand it. I'll have
a bank of microcode images and depending on the string load one of them.

I agree we need some way to support configurable hardware.

> 
>> driver I don't see how/why we should block it for "real" devices.
>>From the kernels point of view these are all real drivers. I could
>> build a qemu model that maps 1:1 with real hardware and do a drop
>> in replacement.
>>
>>>
>>> Rocker has a notion of "worlds". When a port is set to be in a certain
>>> world, it behaves in completely different way. Now we have just OF-DPA
>>> world. I will be adding BPF world shortly.
>>>
>>> This has nothing to do with profiles as you describe it, this is
>>> something completely different!
>>>
>>>
>>
>> I'm missing why its different.
>>
>> Would you object to me adding multiple worlds to fm10k
>> using opaque strings? I'll create a world with a topology that maps
>> well to ipv4 networks, a world for ipv6 networks, a world for l2 flat
>> networks, etc. Each world in this example will have a specific table
> 
> Not worlds in rocker terminology. This is what you call profiles.
> 
> 
>> topology and parser to support it. In this sense the ports will behave
>> in completely different ways i.e. packets will be processed by
>> different pipelines. Are you suggesting we do this?
> 
> No, I definitelly do not suggest this. Again, this is what you call "profile".
> I don't care about those, not in the scope of this patchset.
> 

hmm maybe you can explain to me what makes a change large enough
to be called a "world" and where it is a "profile"?

[...]

skipped a few comments because I think they were interesting but not
the point I was trying to ask.

>> Its related in that if you expose your device model you do not need
>> opaque strings to do wholesale reconfiguration of the device. Instead
>> if the parts of the device that are configurable are exposed to the
>> user they can build the "world" they want.
> 
> No, this is not about building. This is about choosing from fixed-sized
> pre-defined list of choices. Again, no "profiles".
> 

But I can just expose a list of pre-defined choices that map to what
I call "profiles". Must be missing the point help me understand what
a world is vs profile?

Maybe our goals are not actually conflicting. Do you have any objection
to pushing configuration code to create tables, insert a new parser,
and change the table topology, and then bind the tables to software
subsystems like fdb, l3, tc, nft, bpf, etc.

.John
