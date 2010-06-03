From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about an assignment in handle_ing()
Date: Thu, 3 Jun 2010 18:01:30 +1000
Message-ID: <20100603080130.GA29709@gondor.apana.org.au>
References: <1274781067.3878.872.camel@bigi> <20100525102603.GA11494@gondor.apana.org.au> <1274789024.3878.919.camel@bigi> <20100525121202.GA12712@gondor.apana.org.au> <1274790038.3878.926.camel@bigi> <20100525124636.GA13161@gondor.apana.org.au> <1274793216.3878.947.camel@bigi> <20100525231307.GA19475@gondor.apana.org.au> <1274873881.3878.988.camel@bigi> <1275226150.3587.9.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:33916 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932558Ab0FCIBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 04:01:40 -0400
Content-Disposition: inline
In-Reply-To: <1275226150.3587.9.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 30, 2010 at 09:29:10AM -0400, jamal wrote:
>
> I have constructed a test case (attached) and my fear is unfortunately
> still there;-< What am i doing wrong?
> 
> The packet path is:
> -->eth0-->tcpdump eth0-->pedit-->mirror to dummy0-->tcpdump dummy0

Well this doesn't guarantee a cloned packet at all.  Once af_packet
receives the packet it'll wake up any listeners like tcpdump, if
tcpdump gets to it before pedit runs then the packet won't be
cloned anymore.

Anyway, I don't see why actions are special.  Everybody else lives
by the rule that cloned skbs are not writeable.  So if this was
indeed buggy as you say it would have shown up a long time ago.

Case in point, we had a bug in certain NIC drivers where they
modified cloned skbs for TSO.  This quickly showed up as bogus
packets in tcpdump and we fixed it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
