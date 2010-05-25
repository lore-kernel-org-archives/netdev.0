From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about an assignment in handle_ing()
Date: Tue, 25 May 2010 22:12:02 +1000
Message-ID: <20100525121202.GA12712@gondor.apana.org.au>
References: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com> <1274781067.3878.872.camel@bigi> <20100525102603.GA11494@gondor.apana.org.au> <1274789024.3878.919.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:58606 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755010Ab0EYMML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 08:12:11 -0400
Content-Disposition: inline
In-Reply-To: <1274789024.3878.919.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 25, 2010 at 08:03:44AM -0400, jamal wrote:
> On Tue, 2010-05-25 at 20:26 +1000, Herbert Xu wrote:
> 
> > In that case you should be checking whether the skb is cloned.
> 
> That is the general rule used (and what i specify to do in the docs)..
> but i recall there were issues if the packet path emanated from ingress
> and included multiple netdevices (earlier ex with mirror applies). There
> may have been bugs then, eg I could not assume that it i had any ptype
> at all that the ptype will clone the packet. Does tcpdump guarantee
> skb->clone being set? I will try to test some scenarios when i am back
> +settled. 

It is guaranteed, it is illegal to hold onto the skb contents
without the reference that comes from cloning an skb.

> "Most" for people running serious firewalls or routers is not to run
> DHCP servers;-> They may client, but thats a short-lived session.

The DHCP client may keep the AF_PACKET open even if there is no
ongoing dialogue.

> > Also
> > the skb may still be cloned even if there is no AF_PACKET listener.
> > In that case your optimisation may be incorrect.
> 
> Did you mean that as long as there are other ptypes - which may or 
> not be doing af packet? 

For ingress, the packet may have looped back from a virtual
interface.  It may have been cloned on its way out of the virtual
interface.

Looking at ptype instead of checking whether the skb is cloned
simply doesn't work in this case.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
