From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Thu, 09 Jan 2014 23:32:59 -0800
Message-ID: <1389339179.31367.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140109201411.317040@gmx.com>
	 <20140110063638.GA17866@order.stressinduktion.org>
	 <1389337306.31367.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140110071049.GB17866@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:39625 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbaAJHdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 02:33:01 -0500
Received: by mail-pa0-f44.google.com with SMTP id fa1so4441453pad.3
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 23:33:00 -0800 (PST)
In-Reply-To: <20140110071049.GB17866@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 08:10 +0100, Hannes Frederic Sowa wrote:
> On Thu, Jan 09, 2014 at 11:01:46PM -0800, Eric Dumazet wrote:
> > Its not clear to me why you expand ipmr_fib_lookup()
> > 
> > Is there something wrong with existing code ?
> 
> There are three users of ipmr_fib_lookup, two of them are in rcu_read_lock
> section, one is not.
> 
> ipmr_fib_lookup does not pass down arg.rule reference, so I don't have a
> chance to call fib_rule_put(arg.rule) on it. Thus I left ipmr_fib_lookup,
> just adding FIB_LOOKUP_NOREF and expanding ipmr_fib_lookup into the
> other function so I still have access to arg.rule to decrement the
> reference counter.
> 
> Do you agree?

Hmm, I see the problem now.

What about adding a parameter to ipmr_fib_lookup(),
to keep its spirit ?

ipmr_fib_lookup(net, &fl4, &mrt);
->
ipmr_fib_lookup(net, &fl4, &mrt, &rule);

Since ipmr_rt_fib_lookup() has the same rule leak, no ?

Its a bit late here, so maybe following is just stupid :
Cant we do the fib_rule_put() inside ipmr_fib_lookup() ?
