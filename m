From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net v2] ipv6: clean up dev_snmp6 proc entry when we fail
 to initialize inet6_dev
Date: Wed, 4 Nov 2015 16:36:54 +0100
Message-ID: <20151104153654.GA22004@bistromath.redhat.com>
References: <94ceff1a1f708ce80664370c783f7bfb066fccb5.1446577025.git.sd@queasysnail.net>
 <1446650594.4184.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, dvyukov@google.com,
	hannes@stressinduktion.org, cwang@twopensource.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932491AbbKDPg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 10:36:57 -0500
Content-Disposition: inline
In-Reply-To: <1446650594.4184.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-11-04, 07:23:14 -0800, Eric Dumazet wrote:
> On Wed, 2015-11-04 at 14:47 +0100, Sabrina Dubroca wrote:
> > In ipv6_add_dev, when addrconf_sysctl_register fails, we do not clean up
> > the dev_snmp6 entry that we have already registered for this device.
> > Call snmp6_unregister_dev in this case.
> > 
> > Reported-by: Dmitry Vyukov <dvyukov@google.com>
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > ---
> > 
> > v2: we cannot call snmp6_unregister_dev from addrconf_core.c, this
> >     breaks CONFIG_IPV6=m, instead do the clean up directly from
> >     ipv6_add_dev
> >     thanks Cong.
> 
> Any idea when the bug was added ?
> 
> Can we please add a proper Fixes: tag for patches that need to be
> backported to stable versions ?
> 
> It seems to be
> 
> Fixes: a317a2f19da7d ("ipv6: fail early when creating netdev named all or default")
> 
> So this goes back to linux-3.17 ?
> 
> Thanks a lot Sabrina !

Sorry, I didn't do the archeology (well, run git blame).  That looks
correct, thanks Eric.

-- 
Sabrina
