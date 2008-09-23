From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 18:40:12 -0700 (PDT)
Message-ID: <20080922.184012.212424947.davem@davemloft.net>
References: <20080922232428.GA25711@one.firstfloor.org>
	<20080922.162158.223213897.davem@davemloft.net>
	<20080923001409.GB25711@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58817
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753870AbYIWBkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 21:40:24 -0400
In-Reply-To: <20080923001409.GB25711@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 23 Sep 2008 02:14:09 +0200

> Typical case: you got a large company network behind a NAT.
> First user has a very crappy wireless connection behind a slow
> intercontinental link talking to the outgoing NAT router. He connectes to 
> your internet server first and the window, slow start etc. parameters 
> for him are saved in the dst_entry.  
> 
> The next guy behind the same NAT is in the same building
> as the router who connects the company to the internet. He
> has a much faster line. He connects to the same server. 
> They will share the same dst and inetpeer entries.
> 
> The parameters saved earlier for the same IP are clearly invalid
> for the second case. The link characteristics are completely 
> different.

Just as typical are setups where the NAT clients are 1 or 2
fast hops behind the firewall.

There are many cases where perfectly acceptible heuristics
don't perform optimally, this doesn't mean we disable them
by default.

> Also did you know there are there are whole countries behind
> NAT.

I am more than aware of this, however this doesn't mean it is
sane and this kind of setup makes many useful internet services
inaccessible.

> Ah I see there's a sysctl now to disable this. How about
> setting it by default?

It's for debugging.
