From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 08:08:28 -0800
Message-ID: <54C271FC.4080105@gmail.com>
References: <54C11ACC.5010005@mojatatu.com> <20150123101019.GF25797@casper.infradead.org> <20150123102421.GB2065@nanopsycho.orion> <20150123110821.GH25797@casper.infradead.org> <20150123113934.GD2065@nanopsycho.orion> <20150123122838.GI25797@casper.infradead.org> <20150123134315.GF2065@nanopsycho.orion> <20150123140724.GJ25797@casper.infradead.org> <54C26A1F.6060603@gmail.com> <20150123155332.GJ2065@nanopsycho.orion> <20150123160058.GN25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:44498 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbAWQIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 11:08:45 -0500
Received: by mail-oi0-f42.google.com with SMTP id i138so5234230oig.1
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 08:08:44 -0800 (PST)
In-Reply-To: <20150123160058.GN25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2015 08:00 AM, Thomas Graf wrote:
> On 01/23/15 at 04:53pm, Jiri Pirko wrote:
>> Fri, Jan 23, 2015 at 04:34:55PM CET, john.fastabend@gmail.com wrote:
>>> What I don't have a lot of use for at the moment is an xflows that runs
>>> in software? Conceptually it sounds fine but why would I want to mirror
>>> hardware limitations into software? And if I make it completely generic
>>> it becomes u32 more or less. I could create an optimized version of the
>>> hardware dataplane in userspace which sits somewhere between u32 and the
>>> other classifiers on flexility and maybe gains some performance but I'm
>>> at a loss as to why this is useful. I would rather spend my time getting
>>> better performance out of u32 and dropping qdisc_lock completely then
>>> writing some partially useful filter for software.
>>
>> Well, even software implementation has limitations. Take ovs kernel
>> datapath as example. You can use your graphs to describe exactly what
>> ovs can handle. And after that you could use xflows api to set it up as
>> well as your rocker offload. That to me seems lie a very nice feature to
>> have.
>
> What is the value of this? The OVS kernel datapath is already built to
> fall back to user space if the kernel datapath does not support a
> specific feature.
>

I might be reaching.. but one advantage of something like this API is
the headers are not pre-defined nor are the actions. Coupled with eBPF
or a generic parser (think optimized u32) you would provide the ability
to configure the OVS fields in use and the actions being supported. Also
I haven't thought about it as much but if you had programmable hardware
and/or software you could create the set operations for headers, tables,
actions. I've done some work on the set tables because its relatively
common on existing hardware. Its on github in the flow tool and the
user space tester flowd.

I think the OVS folks have been thinking along these lines. Of course
your still bound by OF1.x at the moment.

.John

-- 
John Fastabend         Intel Corporation
