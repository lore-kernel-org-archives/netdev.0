From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [GIT/PATCH v4] xen network backend driver
Date: Thu, 10 Mar 2011 17:30:13 +0000
Message-ID: <1299778213.2807.11.camel@bwh-desktop>
References: <1299776554.17339.824.camel@zakaz.uk.xensource.com>
	 <20110310091555.0fa8764d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36081 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461Ab1CJRaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 12:30:17 -0500
In-Reply-To: <20110310091555.0fa8764d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-10 at 09:15 -0800, Stephen Hemminger wrote:
> On Thu, 10 Mar 2011 17:02:33 +0000
> Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > +struct xenvif {
> > +	/* Unique identifier for this interface. */
> ...
> > +	struct net_device_stats stats;
> > +
> 
> There is already a stats struct in net_device in current kernel
> versions, unless there is a compelling reason otherwise
> please use that.
> 
> Also, you probably want to implement per-cpu and 64 bit
> stats.

The driver is using a single queue, so I don't see what benefit it would
get from per-cpu stats.  At some point it should become multiqueue and
then it should store per-queue stats.

64-bit stats are definitely preferable, but since they're being
maintained on the data path this may require some significant work.
(Ian: see <linux/u64_stats_sync.h> for the canonical way to do this.)
Given that only a relatively few existing drivers do this (I count 13),
I'm not sure we can reasonably demand that a new driver does - yet.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

