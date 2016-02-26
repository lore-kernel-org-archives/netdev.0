From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/3] intermediate representation for jit and
 cls_u32 conversion
Date: Fri, 26 Feb 2016 12:26:57 -0500 (EST)
Message-ID: <20160226.122657.1472671063151796590.davem@davemloft.net>
References: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
	<56CF43D8.1010106@gmail.com>
	<20160226114036.GA2523@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	horms@verge.net.au
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981AbcBZR07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 12:26:59 -0500
In-Reply-To: <20160226114036.GA2523@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 26 Feb 2016 12:47:14 +0100

> The frontend parser should be generic to everyone, it should be
> placed in the core, so everyone will take care of improving it.

Generic unfortunately means information loss and lots of wasted work.

And this is one of John's points I think.

If we have an existing abstraction that fits directly into what the
hardware can do, such as the u32 classifiers, translating this back
and forth into an intermediate representation is going to be at best
wasted work and sometimes missing cases that can be loaded into hardware.

I really see zero value in "generic" intermediate languages for this
kind of stuff.

I don't want to have to translate a set of u32 rules into some other
format if u32 is what lots of hardware can do directly already.

Pablo, you're coming at the from another angle, you're starting from
the perspective of nftables which has this nice abstraction and IR.
But no hardware directly offloads nftables IR.  So as an offload
strategy nftables needs this IR to hardware translation layer.

But u32 and others absolutely will not, and we should not force them
to.
