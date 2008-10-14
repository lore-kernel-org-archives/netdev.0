From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Error: an inet prefix is expected rather than "0/0".
Date: Tue, 14 Oct 2008 20:38:10 +0100
Message-ID: <1224013090.3984.165.camel@achroite>
References: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl>
	 <E1KpkSl-00087W-GB@gondolin.me.apana.org.au>
	 <20081014104621.3c2ce4d3@extreme>
	 <alpine.LNX.1.10.0810142113140.7684@bizon.gios.gov.pl>
	 <20081014121855.2f931be0@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Oledzki <ole@ans.pl>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:49428 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751969AbYJNTiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 15:38:15 -0400
In-Reply-To: <20081014121855.2f931be0@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-14 at 12:18 -0700, Stephen Hemminger wrote:
> On Tue, 14 Oct 2008 21:15:18 +0200 (CEST)
> Krzysztof Oledzki <ole@ans.pl> wrote:
> 
> > 
> > 
> > On Tue, 14 Oct 2008, Stephen Hemminger wrote:
[...]
> > > Busted cases:
> > >                           correct           incorrect
> > > Original code: 127.2   =>  127.0.0.2         127.2.0.0
> > > inet_pton:     10.0    =>  10.0.0.0          fails invalid
> > > inet_aton:     10      =>  10.0.0.0          0.0.0.10
> > >
> > > The problem was Alexey (or Jamal) invented their own abbreviation format
> > > and did not follow unix standard conventions.
> > 
> > It seems that the original code followed the unix standard:
> > 
> > # telnet 127.2
> > Trying 127.0.0.2...
> > telnet: connect to address 127.0.0.2: Connection refused
> 
> The incorrect column lists the actual result for each of the routines.
> Original code converted 127.2 to 127.2.0.0
[...]

If only the one-component case needs to be treated specially then you
should be able to use something like:

	/* For backward compatibility, if name is all digits we treat it as
	 * the top 8 bits of an IPv4 address. */
	if (strspn(name, "0123456789") == strlen(name))
		addr->data[0] = atoi(name);
	else if (inet_aton(name, addr->data) > 0)
		;
	else
 		return -1;

But if people also rely on e.g. 192.168/16 working then it gets
trickier.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

