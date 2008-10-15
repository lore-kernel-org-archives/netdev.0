From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Error: an inet prefix is expected rather than "0/0".
Date: Wed, 15 Oct 2008 17:07:10 +0100
Message-ID: <1224086831.3984.196.camel@achroite>
References: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl>
	 <E1KpkSl-00087W-GB@gondolin.me.apana.org.au>
	 <20081014104621.3c2ce4d3@extreme>
	 <20081015014624.GA3251@gondor.apana.org.au>
	 <m34p3door9.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Krzysztof Oledzki <ole@ans.pl>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:50001 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751757AbYJOQHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 12:07:23 -0400
In-Reply-To: <m34p3door9.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-15 at 17:35 +0200, Krzysztof Halasa wrote:
> Herbert Xu <herbert@gondor.apana.org.au> writes:
> 
> > How about just keeping Alexey's code? POSIX doesn't restrict
> > the IP address format command utilities should accept.  So to
> > me 127.2.0.0 is a perfectly acceptable interpretation of the
> > partial address 127.2.
> 
> Then it would be better to disallow such things. The normal meaning
> for "127.2" was always 127.0.0.2, and it was widely documented and
> used (though perhaps in RFCs, not in POSIX).

It's a Berkeley extension which spread via BSD and its inet_aton()
function.  I don't believe it's specified in any RFC.

> Some people use "10.1" syntax all the time.
> 
> > This also has the benefit of not breaking any existing scripts
> > that already work.  The scripts which are broken will remain
> > broken which doesn't surprise anyone.
> 
> Any script which uses 127.2 to mean 127.2.0.0 is IMHO broken, though
> I have never seen anything like that.
> 
> Rules always have been simple:
> 10	- 10.0.0.0
> 10.1	- 10.0.0.1
> 10.1.2	- 10.0.1.2

No, a single number is treated by inet_aton() as a 32-bit address, so 10
is equivalent to 0.0.0.10.

> If it can't stay this way, lets remove this shortened notation
> completely.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

