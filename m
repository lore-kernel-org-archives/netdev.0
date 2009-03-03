From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
 implementation & Netlink protocol
Date: Tue, 03 Mar 2009 14:14:50 -0800 (PST)
Message-ID: <20090303.141450.98616272.davem@davemloft.net>
References: <20090303170435.GE1480@hmsreliant.think-freely.org>
	<20090303181909.GA29236@ioremap.net>
	<20090303192107.GJ1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40048
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759449AbZCCWPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:15:09 -0500
In-Reply-To: <20090303192107.GJ1480@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 3 Mar 2009 14:21:07 -0500

> On Tue, Mar 03, 2009 at 09:19:09PM +0300, Evgeniy Polyakov wrote:
> > Hi Neil.
> > 
> > On Tue, Mar 03, 2009 at 12:04:35PM -0500, Neil Horman (nhorman@tuxdriver.com) wrote:
> > > +typedef enum {
> > > +	NET_DM_CFG_VERSION = 0,
> > > +	NET_DM_CFG_ALERT_COUNT,
> > > +	NET_DM_CFG_ALERT_DELAY,
> > > +	NET_DM_CFG_MAX,
> > > +} config_type_t;
> > > +
> > > +struct net_dm_config_entry {
> > > +	config_type_t type;
> > > +	uint64_t data;
> > > +};
> > > +
> > 
> > Ugh, please add either some comments about its alignment or some padding
> > fields.
> > 
> Yeah, I probably should align that to 64 bit boundaries for performance, thanks!

Actually you should use "aligned_u64" otherwise there will be
compat issues on 32-bit x86 on x86_64/ia64 since 32-bit x86
only 4-byte aligns 64-bit objects unless told otherwise.

And using anon-fixed type like an enum for "type" is also
likely not such a good idea.  I would just use a __u32
and some defines instead.
