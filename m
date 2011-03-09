From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Cache source address in nexthop entries.
Date: Wed, 09 Mar 2011 15:40:39 -0800 (PST)
Message-ID: <20110309.154039.116392390.davem@davemloft.net>
References: <alpine.LFD.2.00.1103090157400.2880@ja.ssi.bg>
	<20110309.130817.115943793.davem@davemloft.net>
	<alpine.LFD.2.00.1103100014430.2160@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33511
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751978Ab1CIXkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 18:40:02 -0500
In-Reply-To: <alpine.LFD.2.00.1103100014430.2160@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 10 Mar 2011 01:32:18 +0200 (EET)

> On Wed, 9 Mar 2011, David Miller wrote:
> 
>> So device address operations increment a generation ID and
>> FIB_RES_PREFSRC() checks that ID against one stored in the nexthop.
> 
> 	Yes, may be it is better this generation ID to be global
> value for netns, because the global addresses should cause
> refresh for all nexthops on all devices. The ID should be
> matched with corresponding value in NH. Another option is
> to use per-device gen_id instead of netns gen_id but in this
> case scope-global address event should increment gen_id for all
> devices while the device_UP event will increment only
> gen_id for the concerned DEV.
> 
> 	I.e. there are 2 variants:

I think the per-namespace ID makes the most sense.

If the whole idea of the genid is to reduce complication, trying to place
games on a per-device basis wrt. the scope cases seems to work against that
goal :-)

After I try to attack the ipv6 routing regression I added in net-2.6, I'll
take a stab at this.

Thanks!
