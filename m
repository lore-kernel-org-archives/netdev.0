From: jamal <hadi@cyberus.ca>
Subject: Re: Question about an assignment in handle_ing()
Date: Tue, 25 May 2010 08:03:44 -0400
Message-ID: <1274789024.3878.919.camel@bigi>
References: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com>
	 <1274781067.3878.872.camel@bigi>
	 <20100525102603.GA11494@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:62319 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377Ab0EYMDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 08:03:47 -0400
Received: by qyk13 with SMTP id 13so7122207qyk.1
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 05:03:47 -0700 (PDT)
In-Reply-To: <20100525102603.GA11494@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-05-25 at 20:26 +1000, Herbert Xu wrote:

> In that case you should be checking whether the skb is cloned.

That is the general rule used (and what i specify to do in the docs)..
but i recall there were issues if the packet path emanated from ingress
and included multiple netdevices (earlier ex with mirror applies). There
may have been bugs then, eg I could not assume that it i had any ptype
at all that the ptype will clone the packet. Does tcpdump guarantee
skb->clone being set? I will try to test some scenarios when i am back
+settled. 

> After all, tcpdump might have simply filtered the packet out.

True - but i think thats an acceptable compromise.

> BTW, this is the case whenever you run a DHCP client/server.  So
> on most boxes your optimisation will never kick in as is.  

"Most" for people running serious firewalls or routers is not to run
DHCP servers;-> They may client, but thats a short-lived session.

> Also
> the skb may still be cloned even if there is no AF_PACKET listener.
> In that case your optimisation may be incorrect.

Did you mean that as long as there are other ptypes - which may or 
not be doing af packet? 

cheers,
jamal

