From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Sat, 24 Jan 2015 08:01:52 -0500
Message-ID: <54C397C0.3010508@mojatatu.com>
References: <20150122151316.GB25797@casper.infradead.org> <54C11703.7030702@mojatatu.com> <20150122153727.GC25797@casper.infradead.org> <54C11ACC.5010005@mojatatu.com> <20150123101019.GF25797@casper.infradead.org> <20150123102421.GB2065@nanopsycho.orion> <20150123110821.GH25797@casper.infradead.org> <20150123113934.GD2065@nanopsycho.orion> <20150123122838.GI25797@casper.infradead.org> <20150123134315.GF2065@nanopsycho.orion> <20150123140724.GJ25797@casper.infradead.org> <54C26A1F.6060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: John Fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:62052 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbbAXNBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 08:01:55 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so1822502igk.1
        for <netdev@vger.kernel.org>; Sat, 24 Jan 2015 05:01:54 -0800 (PST)
In-Reply-To: <54C26A1F.6060603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/15 10:34, John Fastabend wrote:

> First 'tc' infrastructure doesn't have any classifier that would map
> well to this today so you are talking about a new classifier looks like
> Jiri is calling it xflows. This is fine.

I know you know this (and apologies for the little Australian Bike
Shed tangent):
You can do _any_ classifier you want. xflows just happens to make the
OF people happy. Someone else who wants to classify on pcre like
strings can go ahead and write another one.
i.e there is no monopoly on what a classifier should be.

> Now 'xflows' needs to implement the same get operations that exist in
> this flow API otherwise writing meaningful policies as Thomas points out
> is crude at best.

It is crude only if you assume the kernel is doing your policies
and fixing any conflicts. Let the kernel do mechanisms and have user
space do the brainy part. No need to give total autonomy to the kernel.


> So this tc classifier supports 'get headers',
> 'get actions', and 'get tables' and then there associated graphs. All
> good so far. This is just an embedding of the existing API in the 'tc'
> netlink family. I've never had any issues with this. Finally you build
> up the 'get_flow' and 'set_flow' operations I still so no issue with
> this and its just an embedding of the existing API into a 'tc
> classifier'. My flow tool becomes one of the classifier tools.
>

You have very few generic verbs really within tc and i dont see
much more needed.
GET/SET(mods for create/append/replace)/DEL with the object
being a noun. Add a handful for capabilities exercising verbs and
you should be on your way.
BTW: I did have capabilities in actions for years but Cong sent a
patch about a year or so ago to kill them because they were not being
exercised from user space tc - I protested but Dave overruled me.
There are still remnants - look at struct tcf_common field
tcfc_capab - the original intent was to have that look like netdev
features bitmask. In any case i never got to proper implementation
and have gained a lot of experience since those early days
and my thinking has changed.


> Now what should I attach my filter to? Typically we attach it to qdiscs
> today. But what does that mean for a switch device? I guess I need an
> _offloaded qdisc_? I don't want to run the same qdisc in my dataplane
> of the switch as I run on the ports going into/out of the sw dataplane.

I dont know if you need a qdisc necessarily that sits in hardware.
But you need to anchor your policy somewhere. The ingress qdisc is
really a dummy for this purpose. It is the beggining of the pipeline.
Most of the hardware i have looked at has some anchor point for the
hardware ACLs. Typically around a queue or a port. Sometime i find it
hard to use this model because of vendor SDKs and APIs they offer.

> Similarly I don't want to run the same set of filters. So at this point
> I have a set of qdiscs per port to represent the switch dataplane and
> a set of qdiscs attached to the software dataplane. If people think this
> is worth doing lets do it. It may get you a nice way to manage QOS while
> your @ it.
>

Lets discuss at the meeting. I am just skimming these emails (the
conference is chewing a lot of my time so i will mostly be absent).
Sorry if i am not responding to some things.

cheers,
jamal


>
>
