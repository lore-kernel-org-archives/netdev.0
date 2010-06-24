From: jamal <hadi@cyberus.ca>
Subject: Re: Question about xfrm by MARK feature
Date: Thu, 24 Jun 2010 08:04:54 -0400
Message-ID: <1277381094.3455.92.camel@bigi>
References: <201006231803.17261.lists@egidy.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: "Gerd v. Egidy" <lists@egidy.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62694 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754828Ab0FXME5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 08:04:57 -0400
Received: by vws9 with SMTP id 9so2383296vws.19
        for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 05:04:56 -0700 (PDT)
In-Reply-To: <201006231803.17261.lists@egidy.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gerd,

On Wed, 2010-06-23 at 18:03 +0200, Gerd v. Egidy wrote:
> Hi Jamal,
> 
> while looking through the 2.6.34 changelog I found the xfrm by MARK feature 
> you developed in february. I'm currently working on NAT for ipsec connections 
> and thought your feature might help me.
> 
> For example I have 2 different remote networks with the same ip network each 
> and both of them have a tunnel to the same local network. 

It seems "Same IP network" means that two remote locations will have
exactly same IP address? This is hard of course - but nat may do it..
There's also the nat zones feature that Patrick introduced a while back
that may help you

> I map their IPs to 
> something different so I can distinguish them in the local network. But after 
> the nat the xfrm code sees two tunnels with exactly the same values. So this 
> can't work.
> 

Can you look at the incoming encrypted packet headers and tell if they
are from different remotes? If not, are different remotes coming in via
a different network device? If yes, you can install a tc rule to mark
them as they come in before decryption and that mark should stay with
them even after they get decrypted.

> But if I understood your feature correctly, I can now mark the packets (e.g. 
> in iptables with ... -j MARK --set-mark 1) and have xfrm select the correct 
> ipsec tunnel via the mark. Correct?
> 
> But does your feature also set the mark on packets decrypted by xfrm? I need 
> some way to find out from which tunnel the packet came to correctly treat it. 
> 

Refer to above and also to policy routing.

> Do you know if any of the ipsec solutions for linux (e.g. strongswan, 
> openswan, racoon) already have support for this feature or are developing on 
> it?

AFAIK, only iproute2 can use marks. I believe the ike daemons can be
made to use reqid (as Herbert mentioned) but i am not sure that is 
sufficient for what you want.

cheers,
jamal

