From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v4] xen network backend driver
Date: Fri, 11 Mar 2011 10:22:55 +0000
Message-ID: <1299838975.17339.1882.camel@zakaz.uk.xensource.com>
References: <1299776554.17339.824.camel@zakaz.uk.xensource.com>
	 <20110310091555.0fa8764d@nehalam>  <1299778213.2807.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:4320 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab1CKKW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 05:22:57 -0500
In-Reply-To: <1299778213.2807.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-10 at 17:30 +0000, Ben Hutchings wrote:
> On Thu, 2011-03-10 at 09:15 -0800, Stephen Hemminger wrote:
> > On Thu, 10 Mar 2011 17:02:33 +0000
> > Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > > +struct xenvif {
> > > +	/* Unique identifier for this interface. */
> > ...
> > > +	struct net_device_stats stats;
> > > +
> > 
> > There is already a stats struct in net_device in current kernel
> > versions, unless there is a compelling reason otherwise
> > please use that.

Will do.
 
> > Also, you probably want to implement per-cpu and 64 bit
> > stats.
> 
> The driver is using a single queue, so I don't see what benefit it would
> get from per-cpu stats.  At some point it should become multiqueue and
> then it should store per-queue stats.

Agreed.

> 64-bit stats are definitely preferable, but since they're being
> maintained on the data path this may require some significant work.
> (Ian: see <linux/u64_stats_sync.h> for the canonical way to do this.)
> Given that only a relatively few existing drivers do this (I count 13),
> I'm not sure we can reasonably demand that a new driver does - yet.

Is there an example of a driver which also updates the stats on the
datapath?

If it's ok I'd prefer to defer this change for now though.

Ian.

