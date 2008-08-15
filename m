From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression
	for	iptables nat routing
Date: Thu, 14 Aug 2008 23:49:33 -0600
Message-ID: <1218779373.23510.25.camel@2710p.home>
References: <1218726484.23510.20.camel@2710p.home>
	 <E1KTrAo-0001YG-00@gondolin.me.apana.org.au>
	 <20080815053548.GA6366@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:5361 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbYHOFuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 01:50:15 -0400
In-Reply-To: <20080815053548.GA6366@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-08-15 at 15:35 +1000, Herbert Xu wrote:
> On Fri, Aug 15, 2008 at 02:44:26PM +1000, Herbert Xu wrote:
> > 
> > Actually, I think know what's going on but a raw packet dump should
> > confirm whether we're getting a partial checksum.
> 
> Nevermind, I think I've found the problem.
> 
> loopback: Drop obsolete ip_summed setting
> 
> Now that the network stack can handle inbound packets with partial
> checksums, we should no longer clobber the ip_summed field in the
> loopback driver.  This is because CHECKSUM_UNNECESSARY implies that
> the checksum field is actually valid which is not true for loopback
> packets since it's only partial (and thus complemented).
> 
> This allows packets from lo to then be SNATed to an external source
> while still preserving the checksum's validity.

Nope, that doesn't fix it.  NAT'd throughput remains about the same.
Thanks,

	Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

