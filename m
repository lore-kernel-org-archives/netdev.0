From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/3] net: propagate sock pointer through
 netfilter hooks
Date: Fri, 22 Aug 2014 07:56:57 +0200
Message-ID: <20140822055657.GA1847@nanopsycho.orion>
References: <1408127576-11518-1-git-send-email-jiri@resnulli.us>
 <20140821.173339.1409243624518012670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, stephen@networkplumber.org,
	cwang@twopensource.com, pshelar@nicira.com,
	nicolas.dichtel@6wind.com, therbert@google.com,
	dborkman@redhat.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:58273 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630AbaHVF5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 01:57:01 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so9673423wib.15
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 22:57:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140821.173339.1409243624518012670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 22, 2014 at 02:33:39AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri, 15 Aug 2014 20:32:54 +0200
>
>> When output function (ip6_finish_output2 for example) needs to be called
>> with sock pointer, we need to push sock pointer through the netfilter
>> hooks. This patch does that.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Ok, I'm going to admit that I am having second thoughts about this
>approach.  This is a quite large set of churn to fix this bug.
>
>However, in the same breath, I can't come up with a simpler way to
>propagate this information without the really unacceptable overhead of
>adding another sk_buff member.
>
>And even if we found some simple way to deal with that sk_mc_loop()
>test, ipv6 has other demons in this area.
>
>For example, look at what ip6_fragment() does, it also assumes skb->sk
>is an inet6 socket.
>
>	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
> ...
>	if (np && np->frag_size < mtu) {
>		if (np->frag_size)
>			mtu = np->frag_size;
>	}
>
>The rest of the skb->sk usage in these place is fine, as they are
>simply propagating socket ownership from one packet to another, rather
>than doing protocol specific things with them.


You are correct. Another code can benefit from proparated sk as well. I
found couple of other possible places on the way (which I unfortunatelly
did not noted :/).
