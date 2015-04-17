From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Fri, 17 Apr 2015 19:05:17 +0200
Message-ID: <55313D4D.4050402@redhat.com>
References: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>	 <20150414.143747.1155055158701231768.davem@davemloft.net>	 <552F9986.30207@redhat.com> <1429187895.7346.195.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	jengelh@medozas.de, jpirko@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059AbbDQRFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2015 13:05:21 -0400
In-Reply-To: <1429187895.7346.195.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2015 02:38 PM, Eric Dumazet wrote:
> On Thu, 2015-04-16 at 13:14 +0200, Denys Vlasenko wrote:
> 
>> However, without BUG_ONs, function is still a bit big
>> on PREEMPT configs.
> 
> Only on allyesconfig builds, that nobody use but to prove some points
> about code size.

How do you expect one to find excessively large inlines,
if not on allyesconfig build?

Only by using allyesconfig, I can measure how many calls
are there in the kernel. (grepping source is utterly unreliable
due to nested inlines and macros).

For the record: I am not using the _full_ allyesconfig,
I do disable some debugging options which clearly aren't
ever enabled on production systems. E.g. in my config:

# CONFIG_DEBUG_KMEMLEAK_TEST is not set
# CONFIG_KASAN is not set

etc.

> If you look at net_generic(), it is mostly used from code that is
> normally in 3 modules. How many people really load them ?
> 
> net/tipc : 91 call sites
> net/sunrpc : 57
> fs/nfsd & fs/lockd : 183
> 
> Then few remaining uses in tunnels.

Grepping is far from reliable. The above missed more than half
of all calls. I disassembed vmlinux after deinlining, there are
nearly 500 calls of net_generic().

> As we suggested, please just remove the BUG_ON().

Going to send the patch in a minute.
-- 
vda
