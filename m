From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/14] rocker: add support for multiple worlds
Date: Mon, 5 Oct 2015 18:30:12 +0200
Message-ID: <20151005163012.GO2278@nanopsycho.orion>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
 <56129A32.1010201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com,
	idosch@mellanox.com, eladr@mellanox.com, tgraf@suug.ch,
	ast@plumgrid.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35303 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbbJEQaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 12:30:15 -0400
Received: by wicge5 with SMTP id ge5so128689986wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 09:30:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <56129A32.1010201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 05, 2015 at 05:41:38PM CEST, john.fastabend@gmail.com wrote:
>On 15-10-04 02:25 PM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> This patchset allows new rocker worlds to be easily added in future (like eBPF
>> based one I have been working on). The main part of the patchset is the OF-DPA
>> carve-out. It resuts in OF-DPA specific file. Clean cut.
>> The user is able to change rocker port world/mode using rtnl.
>> 
>
>Hi Jiri,
>
>I'm not sure I understand the motivation here. Are you thinking the
>"real" drivers will start to load worlds or what I've been calling
>profiles on the devices I have here. If this is the case using
>opaque strings without any other infrastructure around it to expose
>what the profile is doing is not sufficient in my opinion. What I
>would rather have is for drivers to expose the actual configuration
>parameters they are using, preferable these would be both readable
>and writable so we don't end up with what the firmware/device driver
>writers think is best. I think we can get there by exposing a model
>of the device and configuring "tables". I'll post my latest patch
>set today to give you a better idea what I'm thinking here. Without
>this I guess you will end up with drivers creating many profiles and
>in no consistent way so you end up with here is my "vxlan" profile,
>here is my "geneve" profile, here is my "magic-foo" profile, etc. I
>wanted to avoid this.

This is just for rocker purposes. I do not want to do something similar
for real devices. It does not make sense as real hw always have some
hard-wired topology. Rocker HW does not. I think that this is the main
part that may cause some misunderstandings.

Rocker has a notion of "worlds". When a port is set to be in a certain
world, it behaves in completely different way. Now we have just OF-DPA
world. I will be adding BPF world shortly.

This has nothing to do with profiles as you describe it, this is
something completely different!


>
>But if this is only meant to be a rocker thing then why expose it on
>the driver side vs just compiling it on the qemu side? If its just

I want user to be able to set the world/mode of the port on fly. No need to
re-set the hardware if possible to do it from driver.


>for convenience and only meant for the emulated device we should be
>clear in the documentation and patch set.

This is rocker-only patchset, where do you want to clear it?


>
>Final, comment can we abstract the interfaces better? An L2 and L3
>table could be mapped generically onto a table pipeline model if the
>driver gave some small hints like this is my l2 table and this is my l3
>table. Then you don't need all the world specific callbacks and the
>OF-DPA model just looks like an instance of a pipeline with some
>specific hints where to put l2/l3 rules.

I think you are missing something, or I am. How do you map BPF world
pipeline into tables? The idea of the worlds is to do *completely*
different HW implementation, not just rewire some pre-defined tables.
For BPF world, there will be just BPF interpreter sitting inside HW
and running arbitrary code, no tables.


>
>Like I said I'll send some patches, they will be a bit rough and
>against fm10k driver. I'll just send out what I have end of day here.

Your patchset sounds totally unrelated to this one. Let's make that clear.
