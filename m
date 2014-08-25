From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/3] net: propagate sock pointer through
 netfilter hooks
Date: Mon, 25 Aug 2014 12:52:01 -0700 (PDT)
Message-ID: <20140825.125201.1587978115657653201.davem@davemloft.net>
References: <20140825140510.GB1871@nanopsycho.lan>
	<20140825.115103.943827907985622489.davem@davemloft.net>
	<20140825192926.GC1871@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, stephen@networkplumber.org,
	cwang@twopensource.com, pshelar@nicira.com,
	nicolas.dichtel@6wind.com, therbert@google.com,
	dborkman@redhat.com, edumazet@google.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbaHYTwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 15:52:05 -0400
In-Reply-To: <20140825192926.GC1871@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 25 Aug 2014 21:29:26 +0200

> Mon, Aug 25, 2014 at 08:51:03PM CEST, davem@davemloft.net wrote:
>>From: Jiri Pirko <jiri@resnulli.us>
>>Date: Mon, 25 Aug 2014 16:05:10 +0200
>>
>>> Dave, I see that the patchset is in state "Changes requested". I do not
>>> think I understand what is needed to be done at this point. Would you
>>> please tell me? Thanks.
>>
>>I said there is too much churn so I want an alternative approach
>>considered.
>>
>>Also want you to fix the ipv6 fragmentation error too.
> 
> 
> Hmm. When skb->x adding is no-go and propagating sk through nf hooks is
> no go, I really do not see the way to fix this... I might be missing
> something though...

Change the order of operations so that sk can be evaluated and tested
earlier in the code paths, before the NF_HOOK executes.

Or only store the boolean result of the test in the sk_buff.

Please, try to be creative, do not just see black and white. :-)
