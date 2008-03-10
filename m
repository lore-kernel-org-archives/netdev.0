From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: command line support for lro
Date: Mon, 10 Mar 2008 18:50:47 +0000
Message-ID: <20080310185045.GG12660@solarflare.com>
References: <1204898997.4220.41.camel@moonstone.uk.level5networks.com> <20080307082538.1a674ae1@extreme> <1204909575.4220.71.camel@moonstone.uk.level5networks.com> <20080307134312.037e2cf6@extreme> <20080310180706.GF12660@solarflare.com> <20080310112949.153a8cd5@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:40466 "EHLO
	pythagoras.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbYCJSuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 14:50:55 -0400
Content-Disposition: inline
In-Reply-To: <20080310112949.153a8cd5@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 10 Mar 2008 18:07:07 +0000
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > Stephen Hemminger wrote:
<snip>
> > > @@ -1559,12 +1566,20 @@ static int do_goffload(int fd, struct ifreq *ifr)
> > >  		allfail = 0;
> > >  	}
> > >  
> > > +	eval.cmd = ETHTOOL_GFLAGS;
> > > +	ifr->ifr_data = (caddr_t)&eval;
> > > +	err = ioctl(fd, SIOCETHTOOL, ifr);
> > > +	if (!err) {
> > > +		lro = eval.data & ETH_FLAG_LRO;
> > > +		allfail = 0;
> > > +	}
> > > +
> > 
> > To be consistent, this should print a specific error if the ioctl
> > fails.
> 
> No, since most hardware won't support LRO or the flags, it makes sense not
> to complain when fetching the value.
<snip>

Many of the other offloads have the same issue, particularly when
using a new ethtool with an old kernel.  Maybe we should not print an
error message if the error is EOPNOTSUPP or EPERM (unknown commands
are assumed to require admin capability).  But that's a separate
change and again it's not specific to LRO.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
