From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 17:16:05 +0100
Message-ID: <20150123161605.GN2065@nanopsycho.orion>
References: <20150123101019.GF25797@casper.infradead.org>
 <20150123102421.GB2065@nanopsycho.orion>
 <20150123110821.GH25797@casper.infradead.org>
 <20150123113934.GD2065@nanopsycho.orion>
 <20150123122838.GI25797@casper.infradead.org>
 <20150123134315.GF2065@nanopsycho.orion>
 <20150123140724.GJ25797@casper.infradead.org>
 <54C26A1F.6060603@gmail.com>
 <20150123155332.GJ2065@nanopsycho.orion>
 <20150123160058.GN25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:56072 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755833AbbAWQQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 11:16:09 -0500
Received: by mail-wg0-f53.google.com with SMTP id a1so8325123wgh.12
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 08:16:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150123160058.GN25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 23, 2015 at 05:00:58PM CET, tgraf@suug.ch wrote:
>On 01/23/15 at 04:53pm, Jiri Pirko wrote:
>> Fri, Jan 23, 2015 at 04:34:55PM CET, john.fastabend@gmail.com wrote:
>> >What I don't have a lot of use for at the moment is an xflows that runs
>> >in software? Conceptually it sounds fine but why would I want to mirror
>> >hardware limitations into software? And if I make it completely generic
>> >it becomes u32 more or less. I could create an optimized version of the
>> >hardware dataplane in userspace which sits somewhere between u32 and the
>> >other classifiers on flexility and maybe gains some performance but I'm
>> >at a loss as to why this is useful. I would rather spend my time getting
>> >better performance out of u32 and dropping qdisc_lock completely then
>> >writing some partially useful filter for software.
>> 
>> Well, even software implementation has limitations. Take ovs kernel
>> datapath as example. You can use your graphs to describe exactly what
>> ovs can handle. And after that you could use xflows api to set it up as
>> well as your rocker offload. That to me seems lie a very nice feature to
>> have.
>
>What is the value of this? The OVS kernel datapath is already built to
>fall back to user space if the kernel datapath does not support a
>specific feature.


As I wrote earlier, the value is that userspace can easily use single
xflows api to take care of all ways to handle flows (ovs kernel dp,
rocker, other device, u32 tc filter + actions, you name it)


    my flow managing app 
          |
uspc      |
  --------|----------------------------------------------------
krnl      |
       tc xflows api
          |  |  |
          |  |  ---------------------------------------------------
          |  |                                                    |
          |  ------------------                                other xflows backend
          |                   |
     ovs xflows backend     rocker driver xflows backend
          |                   |
         ovs dp               |
krnl	                      |
  ----------------------------|--------------------------------
hw                            |
                           rocker switch
