From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net_sched: add 64bit rate estimators
Date: Wed, 5 Jun 2013 21:06:09 +0100
Message-ID: <1370462769.1918.7.camel@bwh-desktop.uk.level5networks.com>
References: <1370408447.24311.241.camel@edumazet-glaptop>
	 <1370458531.1918.3.camel@bwh-desktop.uk.level5networks.com>
	 <1370461057.24311.296.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29577 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757286Ab3FEUGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 16:06:13 -0400
In-Reply-To: <1370461057.24311.296.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 12:37 -0700, Eric Dumazet wrote:
> On Wed, 2013-06-05 at 19:55 +0100, Ben Hutchings wrote:
> > On Tue, 2013-06-04 at 22:00 -0700, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > struct gnet_stats_rate_est contains u32 fields, so the byte per second
> > > field can wrap at 34360Mbit.
> > > 
> > > Add a new gnet_stats_rate_est64 structure to get 64bit bps field, and
> > > switch the kernel to use this structure natively.
> > [...] 
> > >  /**
> > > + * struct gnet_stats_rate_est64 - rate estimator
> > > + * @bps: current byte rate
> > > + * @pps: current packet rate
> > > + */
> > > +struct gnet_stats_rate_est64 {
> > > +	__u64	bps;
> > > +	__u32	pps;
> > > +} __attribute__ ((packed));
> > [...]
> > 
> > Using attribute packed (which should be written as __packed) forces the
> > alignment of each member and the structure as a whole to be 1.  For an
> > architecture where unaligned access is expensive, gcc will make all
> > reads and writes use byte operations.
> > 
> > I think you have to add a dummy __u32 member instead.
> 
> Its exported to userland so __packed is not available. Or has this been
> changed lately ?

Sorry, you're quite right.

> This structure is only used in very slow path, in the rate estimator
> thing, so the unaligned accesses are not a problem at all.
> 
> I made this choice to not increase sizeof(struct Qdisc) and the
> alignments as well.
> 
> If you think there is an issue with userland, we could use a
> gnet_stats_rate_est64_packed in kernel, and a gnet_stats_rate_est64 in
> userland.

If you're sure this is the right trade-off then I accept that.  I
thought you were using packed to ensure the structure layout was
consistent between userland and kernel, and might not have realised the
unfortunate effect on alignment.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
