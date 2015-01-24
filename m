From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Sat, 24 Jan 2015 08:22:22 -0500
Message-ID: <54C39C8E.4@mojatatu.com>
References: <20150123174609.GA23242@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Thomas Graf <tgraf@suug.ch>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:63040 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081AbbAXNWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 08:22:25 -0500
Received: by mail-ie0-f172.google.com with SMTP id rd18so1945113iec.3
        for <netdev@vger.kernel.org>; Sat, 24 Jan 2015 05:22:24 -0800 (PST)
In-Reply-To: <20150123174609.GA23242@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/15 12:46, Thomas Graf wrote:

> I'm not sure I understand the offload qdisc yet. My interpretation
> so far is that it would contain childs which *must* be offloaded.
>
> How would one transparently offload tc in this model? e.g. let's
> assume we have a simple prio qdisc with u32 cls:
>
> eth0
>    prio
>        class
>        class
>        ...
>      u32 ...
>      u32 ...
>

My view is:
It is up to user space to decide on what the policy should do.
The kernel is not paid to think. You tell it what to do and it does it
efficiently. So if you are going to tell it to have a mix and match
of some things to execute in hardware and some in software then
it may shoot someone's big toe.
IOW, user space should decide how a packet is going to flow.
Agreed that we would need a good way to provide this knowledge
to user space.
BTW: Thomas, reading your other email quickly:
the idea that metadata would be carried around on OF pipeline and
some script at the end executes the actions is imo  a hardware
pipeline hack limitation. Why do i want to defer dropping a packet
when some action is telling me to drop it? ;->
For some reason, brcm hardware in particulat requires that i
complete the pipeline first.
I dont know why we need such a limitation in s/ware (and tc will kill
the pipeline when needed).

Sorry, trying to post while doing other things so not paying close
attention to possibly other important details.

cheers,
jamal
