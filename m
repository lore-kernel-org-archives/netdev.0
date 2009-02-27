From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Thu, 26 Feb 2009 17:25:07 -0800
Message-ID: <20090226172507.4b1f90c2@nehalam>
References: <49A4D5D5.5090602@trash.net>
	<20090225061902.GA32430@gondor.apana.org.au>
	<49A4E3F8.4050406@trash.net>
	<49A4F0D7.20304@trash.net>
	<20090225084321.GA1101@gondor.apana.org.au>
	<m163ixk9t2.fsf@fess.ebiederm.org>
	<20090226062257.GA11511@gondor.apana.org.au>
	<m14oyhis31.fsf@fess.ebiederm.org>
	<20090226084924.16cb3e08@nehalam>
	<20090227005945.GB20081@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36216 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300AbZB0BZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 20:25:12 -0500
In-Reply-To: <20090227005945.GB20081@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Feb 2009 08:59:45 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Feb 26, 2009 at 08:49:24AM -0800, Stephen Hemminger wrote:
> >
> > -	rtnl_lock();
> > +	if (!rtnl_trylock())
> > +		return -ERESTARTSYS;
> 
> This is going to spin instead of sleep on contention, is that
> intended?
> 
> Cheers,

It walks all the way back out to VFS, which is what you have to
do since the sysctl may move.
