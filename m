From: Imre Palik <imrep.amz@gmail.com>
Subject: Re: [PATCH] bridge: make it possible for packets to traverse the
 bridge withour hitting netfilter
Date: Mon, 23 Feb 2015 16:24:22 +0100
Message-ID: <54EB4626.4050703@gmail.com>
References: <1423560744-19011-1-git-send-email-imrep.amz@gmail.com> <20150211.142936.951620487173949333.davem@davemloft.net> <54DE2174.6040001@gmail.com> <20150213163703.GC15141@breakpoint.cc> <54DE3851.7000206@gmail.com> <20150213190330.GD15141@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	imrep@amazon.de, aliguori@amazon.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:54807 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbbBWPYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 10:24:33 -0500
In-Reply-To: <20150213190330.GD15141@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/15 20:03, Florian Westphal wrote:
> Imre Palik <imrep.amz@gmail.com> wrote:
>> The trouble is that there are some bridges (with low traffic) where I need netfilter, and some other bridges (carrying lots of traffic), where I don't.  Being able to set things up on a per bridge basis is a powerful thing.
>>
>> I only implemented the global switch because the iptables and arptables support also have one.  If this is what bugs people here, I can remove it, and resubmit.
> 
> I see.  But I agree with David, accepting such patch would pave way
> for all kinds of ugly hacks.
> 
> It seems that technically the best solution would be to allow attaching
> filter rules to devices, but alas, netfilter doesn't support that.
> 
> Alternatively, you patch *might* be ok iff you can get rid of the extra
> userspace-visible configuration knobs, we already have way too many of
> these.

The sysctl can be removed.  But I need some means to switch it off for a given bridge, so I kept the sysfs interface.
If there is a more preferred way to do it, then please let me know.

> You'll also have to figure out how to avoid any run-time dependency on
> br_netfilter module from the bridge core.
> 
> If you can do this, you might be able to get similar effect as your patch
> by replacing
> 
> NF_HOOK with NF_HOOK_COND(..., !(br->flags & NO_NETFILTER))
> 
> or something like this.

This works nicely for the NFPROTO_BRIDGE, NF_BR_PRE_ROUTING case.  Thanks for the idea.
But for the NFPROTO_BRIDGE, NF_BR_FORWARD case the resulting code would be more ugly,
because of the chaining of the entries.

> I don't know how invasive this would be, though.

I will post the cleaned up version in a sec.
It looks way better.   I hope it will be enough ...
