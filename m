From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC] netfilter: ip6_tables: use reasm skb for
 matching
Date: Mon, 4 Nov 2013 16:22:26 +0100
Message-ID: <20131104152226.GA5103@minipsycho.orion>
References: <1383130201-6198-1-git-send-email-jiri@resnulli.us>
 <20131030134100.GD16615@breakpoint.cc>
 <20131030141354.GB1456@minipsycho.orion>
 <20131030144400.GE16615@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:64724 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768Ab3KDPWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 10:22:33 -0500
Received: by mail-ee0-f49.google.com with SMTP id e52so1178290eek.22
        for <netdev@vger.kernel.org>; Mon, 04 Nov 2013 07:22:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131030144400.GE16615@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 30, 2013 at 03:44:00PM CET, fw@strlen.de wrote:
>Jiri Pirko <jiri@resnulli.us> wrote:
>> >This is a bit backwards, I think.
>> >- We gather frags
>> >- Then we invoke ip6t_do_table for each individual fragment
>> >
>> >So basically your patch is equivalent to
>> >for_each_frag( )
>> >  ip6t_do_table(reassembled_skb)
>> >
>> >Which makes no sense to me - why traverse the ruleset n times with the same
>> >packet?
>> 
>> Because each fragment need to be pushed through separately.
>
>Why?  AFAIU we only need to ensure that (in forwarding case) we
>send out the original fragments instead of the reassembled packet.

I don't knot why, that's the way it is done now. From the top of my head
I can't think of any scenario why it would hurt to push the reassebled
packet instead (and of course send out original fragments at the end of
the way for forwarding)

>
>> What different approach would you suggest?
>
>I am sure that current behaviour is intentional, so I'd first like to
>understand WHY this was implemented this way.
>
>Also, this would change very long standing behaviour so one might argue that
>this is a no-go anyway.

Can you think aof any sane use case this change could possible break?

>
>What is the exact problem that this is supposed to solve?

Look at the patch description. There's an example. The problem is that
fragments are not correctly matched.
