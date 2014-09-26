From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip_tunnel: Don't allow to add the same tunnel
 multiple times.
Date: Fri, 26 Sep 2014 00:43:00 -0400 (EDT)
Message-ID: <20140926.004300.883593012234297777.davem@davemloft.net>
References: <20140922071108.GY6390@secunet.com>
	<20140922.164556.736459936247558402.davem@davemloft.net>
	<20140923113051.GZ6390@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbaIZEnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 00:43:02 -0400
In-Reply-To: <20140923113051.GZ6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 23 Sep 2014 13:30:51 +0200

> On Mon, Sep 22, 2014 at 04:45:56PM -0400, David Miller wrote:
>> From: Steffen Klassert <steffen.klassert@secunet.com>
>> Date: Mon, 22 Sep 2014 09:11:08 +0200
>> 
>> > When we try to add an already existing tunnel, we don't return
>> > an error. Instead we continue and call ip_tunnel_update().
>> > This means that we can change existing tunnels by adding
>> > the same tunnel multiple times. It is even possible to change
>> > the tunnel endpoints of the fallback device.
>> > 
>> > We fix this by returning an error if we try to add an existing
>> > tunnel.
>> > 
>> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>> > ---
>> > 
>> > I was not able to find a commit that introduced this bug.
>> > Looks like ipip and ip_gre had similar bugs already with
>> > the initial git commit.
>> 
>> I'm not so sure about this, perhaps the behavior of being able to
>> change a configuration using an ADD call is intentional?
> 
> Hm, I don't think so. Initially it was the same like with ipv6.
> It was possible to add the same tunnel muliple times without
> getting an error, no config change was made. The possibilty
> to change the configuration by adding the same tunnel a second
> time came with the tunnel code unification.

Ok, makes sense.  Applied, thanks Steffen.

If I had a euro for every regression introduced by that tunnel
unification patch set I'd be a rich man indeed :-/
