From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 09/14] rocker: add rtnl ops for port mode [gs]etting
Date: Mon, 05 Oct 2015 10:43:23 -0700
Message-ID: <5612B6BB.4020402@gmail.com>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us> <1443993949-3915-10-git-send-email-jiri@resnulli.us> <CAE4R7bA6+_WUQ5BXD54zQK7DM64P3FS5D+TdUc1gcpbjd1+oZw@mail.gmail.com> <56129CD0.50301@gmail.com> <20151005163738.GP2278@nanopsycho.orion> <5612AE52.9040809@gmail.com> <20151005172407.GS2278@nanopsycho.orion>
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
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33185 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbbJERnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:43:37 -0400
Received: by pacex6 with SMTP id ex6so183132825pac.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:43:36 -0700 (PDT)
In-Reply-To: <20151005172407.GS2278@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-10-05 10:24 AM, Jiri Pirko wrote:
> Mon, Oct 05, 2015 at 07:07:30PM CEST, john.fastabend@gmail.com wrote:
> 
> <snip>
> 
>>>
>>> Again, to make this clear, worlds are not just a rehash of tables.
>>>
>>
>> what are they then? Lets model those bits and let users configure them
>> at runtime.
>>
>> So far I've had really good results modelling hardware as a 'parser',
>> a set of tables, and a set of modify blocks. Now this breaks when you
>> start to add black boxes in there for other functions such as encryption
>> but I don't think your getting at that. Do you see something that
>> couldn't be configured/modelled with those blocks?
> 
> How about an arbitrary BPF program? I can implement world that bases
> mangling/forwarding packets on intensity of gravitational field.
> Rocker hw is very free in that and cannot be pushed down to "table boxes".
> 
> That is making it a wild animal and challenges us to wrap it up in
> kernel, somehow.
> 

Just for fun ;)

I would model this as a parser that matches on gravitational field and
and an action that does mangling/forwarding.

So a table,

	table { name "gravitational_field_table",
		id 10,
		size 1024,
		matches {(gfield,mask)},
		actions {mangle, forward},
	      }

rules would look like,

 match (gfield=0x1000, mask(0xff00)) -> action (mangle), action(forward)

The user can populate these tables using some interface, the ebpf maps
API looks nice and then programs running against hardware and software
use the same API. Or the hardware could populate the table using a
learning algorithm of some sort. Also you could push your bpf program
to user space via an API so that we can create a software equiv of your
hardware.

I think we can tame the wild animal a bit by scoping it to the set of
useful bpf programs. I guess we can argue about what useful is in this
context. I'm going to argue forwarding by gravitational fields is going
to be not so useful in practice.

Thanks,
.John
