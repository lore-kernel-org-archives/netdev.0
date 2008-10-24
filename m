From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] per-nic module parameters
Date: Fri, 24 Oct 2008 22:01:30 +0100
Message-ID: <20081024210128.GS7331@solarflare.com>
References: <49022B7F.8080809@myri.com> <20081024133920.6588026c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brice Goglin <brice@myri.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:51951 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753254AbYJXVBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 17:01:38 -0400
Content-Disposition: inline
In-Reply-To: <20081024133920.6588026c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Fri, 24 Oct 2008 22:09:35 +0200
> Brice Goglin <brice@myri.com> wrote:
> 
> > Hello,
> > 
> > We're working on making myri10ge module parameters per-nic. It looks
> > like ixgb already does so with the following macro in ixgb_param.c:
> > 
> > #define IXGB_PARAM_INIT { [0 ... IXGB_MAX_NIC] = OPTION_UNSET }
> > #define IXGB_PARAM(X, desc)                                     \
> >         static int __devinitdata X[IXGB_MAX_NIC+1]              \
> >                 = IXGB_PARAM_INIT;                              \
> >         static unsigned int num_##X = 0;                        \
> >         module_param_array_named(X, X, int, &num_##X, 0);       \
> >         MODULE_PARM_DESC(X, desc);
> > 
> > Is this the recommended way to implement per-nic module params? Or
> > should we do something else?
> 
> Module parameters are bad. They are device specific and awkward for
> any general configuration system to deal with. As much as possible,
> please convert any module parameters to real interfaces like netlink,
> ethtool, or sysfs.

I agree in principle.  However, every distribution uses modutils and allows
default module parameters to be set in the same way.  So it's easy to tell
customers how to configure module parameters persistently.  The same cannot
be said for ethtool, unfortunately.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
