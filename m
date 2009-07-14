From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Tue, 14 Jul 2009 09:35:20 -0700 (PDT)
Message-ID: <20090714.093520.136169461.davem@davemloft.net>
References: <20090713133225.GA20946@urbino.open.ch>
	<20090713.104433.244099298.davem@davemloft.net>
	<20090714071410.GA4793@urbino.open.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, kaber@trash.net
To: aj@open.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56581
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755452AbZGNQfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 12:35:16 -0400
In-Reply-To: <20090714071410.GA4793@urbino.open.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Jaggi <aj@open.ch>
Date: Tue, 14 Jul 2009 09:14:10 +0200

> On Mon, Jul 13, 2009 at 10:44:33AM -0700, David Miller wrote:
>> Why not just create a new IFLA_GRE_* attribute to pass in
>> flags like this that purely are private to the GRE Linux
>> tunnel driver and have nothing to do with values defined
>> by GRE tunnel headers at all?
> 
> OK. What would be an appropriate place to store such a private flag in
> the GRE driver?
> 
> I thought of extending the ip_tunnel_parms struct with '__u16 priv_flags'
> (But this would break compatibility with the iproute2 tools?)

You'll need to find a place.  Worst case you can make a top-level
new structure, that contains the user interface structure and
then the new __u16 priv_flags thing.  And allocate that per-tunnel
instead of what it does now.
