From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Fri, 10 Jan 2014 08:10:49 +0100
Message-ID: <20140110071049.GB17866@order.stressinduktion.org>
References: <20140109201411.317040@gmx.com> <20140110063638.GA17866@order.stressinduktion.org> <1389337306.31367.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53350 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbaAJHKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 02:10:50 -0500
Content-Disposition: inline
In-Reply-To: <1389337306.31367.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 11:01:46PM -0800, Eric Dumazet wrote:
> Its not clear to me why you expand ipmr_fib_lookup()
> 
> Is there something wrong with existing code ?

There are three users of ipmr_fib_lookup, two of them are in rcu_read_lock
section, one is not.

ipmr_fib_lookup does not pass down arg.rule reference, so I don't have a
chance to call fib_rule_put(arg.rule) on it. Thus I left ipmr_fib_lookup,
just adding FIB_LOOKUP_NOREF and expanding ipmr_fib_lookup into the
other function so I still have access to arg.rule to decrement the
reference counter.

Do you agree?
