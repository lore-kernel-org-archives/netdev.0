From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] ipv4: gre: add GRO capability
Date: Thu, 27 Sep 2012 20:19:50 +0200
Message-ID: <1348769990.5093.1584.camel@edumazet-glaptop>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
	 <1348769294.5093.1566.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48410 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180Ab2I0STz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 14:19:55 -0400
Received: by bkcjk13 with SMTP id jk13so2305815bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 11:19:54 -0700 (PDT)
In-Reply-To: <1348769294.5093.1566.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 20:08 +0200, Eric Dumazet wrote:

> 
> This sounds not feasible with all kind of tunnels, for example IPIP
> tunnels, or UDP encapsulation, at least with current stack (not OVS)
> 
> Also note that pushing earlier means forcing the checksumming earlier
> and it consumes a lot of cpu cycles. Hopefully NIC will help us in the
> future.
> 
> Using a napi_struct permits to eventually have separate cpus, and things
> like RPS/RSS to split the load.

Also please note that my implementation doesnt bypass first IP stack
traversal (and firewalling if any), so its changing nothing in term
of existing setups.

So packets that should be forwarded will stay as they are (no tunnels
decapsulation/recapsulation)

Doing this in the generic GRO layer sounds a bit difficult.
