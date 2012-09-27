From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] ipv4: gre: add GRO capability
Date: Thu, 27 Sep 2012 20:08:14 +0200
Message-ID: <1348769294.5093.1566.camel@edumazet-glaptop>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39885 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab2I0SIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 14:08:19 -0400
Received: by bkcjk13 with SMTP id jk13so2288576bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 11:08:17 -0700 (PDT)
In-Reply-To: <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 10:52 -0700, Jesse Gross wrote:

> When I was thinking about doing this, my original plan was to handle
> GRO/GSO by extending the current handlers to be able to look inside
> GRE and then loop around to process the inner packet (similar to what
> is done today with skb_flow_dissect() for RPS).  Is there a reason to
> do it in the device?
> 
> Pushing it earlier/later in the stack obviously increases the benefit
> and it will also be more compatible with the forthcoming OVS tunneling
> hooks, which will be flow based and therefore won't have a device.
> 
> Also, the next generation of NICs will support this type of thing in
> hardware so putting the software versions very close to the NIC will
> give us a more similar abstraction.

This sounds not feasible with all kind of tunnels, for example IPIP
tunnels, or UDP encapsulation, at least with current stack (not OVS)

Also note that pushing earlier means forcing the checksumming earlier
and it consumes a lot of cpu cycles. Hopefully NIC will help us in the
future.

Using a napi_struct permits to eventually have separate cpus, and things
like RPS/RSS to split the load.
