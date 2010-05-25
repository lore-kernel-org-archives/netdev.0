From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about an assignment in handle_ing()
Date: Tue, 25 May 2010 20:26:03 +1000
Message-ID: <20100525102603.GA11494@gondor.apana.org.au>
References: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com> <1274781067.3878.872.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:59404 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932380Ab0EYK0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 06:26:13 -0400
Content-Disposition: inline
In-Reply-To: <1274781067.3878.872.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 25, 2010 at 05:51:07AM -0400, jamal wrote:
> The code is correct. 
> 
> Main reason for the else condn is driven by optimization:
> If you are running tcpdump or other af packet type code, the "if" condn
> is hit and matching actions are not allowed trample on that same packet
> data. They have to make a private copy; otherwise, the "else" is hit and
> (for optimization reason) you give ok to the actions that follow to
> munge the packet. Essentially, you dont want actions to alloc/copy every
> single time when you are not running tcpdump for example; reason is that
> most of the time you run tcpdump it is for debugging.
> [I had seen very observable differences on some old mips board back in
> the day on whether you avoided copy every time vs when debugging by
> running tcpdump and copied every packet.]

In that case you should be checking whether the skb is cloned.
After all, tcpdump might have simply filtered the packet out.

BTW, this is the case whenever you run a DHCP client/server.  So
on most boxes your optimisation will never kick in as is.  Also
the skb may still be cloned even if there is no AF_PACKET listener.
In that case your optimisation may be incorrect.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
