From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 09/14] rocker: add rtnl ops for port mode [gs]etting
Date: Mon, 05 Oct 2015 10:07:30 -0700
Message-ID: <5612AE52.9040809@gmail.com>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us> <1443993949-3915-10-git-send-email-jiri@resnulli.us> <CAE4R7bA6+_WUQ5BXD54zQK7DM64P3FS5D+TdUc1gcpbjd1+oZw@mail.gmail.com> <56129CD0.50301@gmail.com> <20151005163738.GP2278@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36750 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbbJERHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:07:44 -0400
Received: by pablk4 with SMTP id lk4so181310633pab.3
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:07:44 -0700 (PDT)
In-Reply-To: <20151005163738.GP2278@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>> Does this mean there is going to be a "ip link set dev DEV type rocker
>>> mode MODE" command option?
>>>
>>> It doesn't seem right to be adding driver-specific IFLA_'s here.  I
>>> think this sets bad precedence for other drivers to add their own
>>> knobs without thinking about a generic shared mechanism.
>>>
>>> Actually, I don't see the point of letting the user dynamically change
>>> the port mode.  I would prefer this knob be moved to qemu/rocker.  Let
>>> the port mode be specified on device creation.
>>>
>>
>> I agree until we have the infrastructure to "understand" what these
>> knobs are fundamentally doing I would prefer it to stay in qemu/rocker.
> 
> Why? If it is possible to set it from driver, why not to expose this to
> user? I don't see a point.


> 
> Let's find an interface and do it. Note that this is far from the first
> thing that could be set from userspace and is not possible, just because
> there is no suitable interface. Vendors then come up with some arbitrary
> blob-based solution to do it. Far from nice :/


I think I've been one of the folks pushing for exposing the hardware :)

My issue with this is its very close to pushing the blob itself. Its
basically an opaque reference to the binary blob itself with no way
to understand what the blob is doing. And no way to standardize the
blobs across hardware.

> 
> 
>>
>> I would rather see commands like "add a table", "remove a table", "add
>> header x to parser" where the operations are well defined. This lends
>> itself well to flexible devices that can be configured at runtime. At
>> least this fits more into my mental model of how we have been managing
>> these devices today. This would allow users to push the "worlds" into
>> the device to match their use cases e.g. add more l3 ipv4 rules vs l3
>> ipv6 rules etc.
> 
> Again, to make this clear, worlds are not just a rehash of tables.
> 

what are they then? Lets model those bits and let users configure them
at runtime.

So far I've had really good results modelling hardware as a 'parser',
a set of tables, and a set of modify blocks. Now this breaks when you
start to add black boxes in there for other functions such as encryption
but I don't think your getting at that. Do you see something that
couldn't be configured/modelled with those blocks?

.John
