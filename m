From: "Gerd v. Egidy" <lists@egidy.de>
Subject: Re: Question about xfrm by MARK feature
Date: Fri, 25 Jun 2010 09:35:30 +0200
Message-ID: <201006250935.30967.lists@egidy.de>
References: <201006231803.17261.lists@egidy.de> <1277381094.3455.92.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs02.intra2net.com ([81.169.173.116]:57944 "EHLO
	rs02.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab0FYHfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 03:35:34 -0400
In-Reply-To: <1277381094.3455.92.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

thanks for your detailed answer.

> > For example I have 2 different remote networks with the same ip network
> > each and both of them have a tunnel to the same local network.
> 
> It seems "Same IP network" means that two remote locations will have
> exactly same IP address?

yes

> This is hard of course - but nat may do it..
> There's also the nat zones feature that Patrick introduced a while back
> that may help you

I'm using Patricks conntrack zones. And Patrick helped me with a input chain 
in the nat table. The other cases with e.g. a ip clash between local and 
remote net already work.

So only the case with two remotes and same ips is missing.

> > I map their IPs to
> > something different so I can distinguish them in the local network. But
> > after the nat the xfrm code sees two tunnels with exactly the same
> > values. So this can't work.
> 
> Can you look at the incoming encrypted packet headers and tell if they
> are from different remotes? If not, are different remotes coming in via
> a different network device? If yes, you can install a tc rule to mark
> them as they come in before decryption 

I planned to avoid looking at the remote gateway ip (to even allow two 
different remote gateways hiding natted behind the same ip) but that would be 
a good fallback solution if my other ideas don't work out.

> and that mark should stay with
> them even after they get decrypted.

Didn't know that, very good.

I just contacted the strongswan maintainers about reqids and marks. Let's see 
if this works out...

Kind regards,

Gerd

-- 
Address (better: trap) for people I really don't want to get mail from:
jonas@cactusamerica.com
