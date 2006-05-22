From: James Morris <jmorris@namei.org>
Subject: Re: [PATCHSET 0/7] SECMARK 2.0
Date: Sun, 21 May 2006 22:46:00 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605212237160.20595@d.namei>
References: <Pine.LNX.4.64.0605180458130.569@d.namei> <20060521165435.7cafbc7c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, kaber@trash.net, sds@tycho.nsa.gov,
	netdev@vger.kernel.org, kmacmillan@tresys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:24503 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964987AbWEVCqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 May 2006 22:46:03 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060521165435.7cafbc7c.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 21 May 2006, Andrew Morton wrote:

> Well as discussed off-list, I'm not able to get this stuff to work.  I get
> a pile of these:
> 
> security_compute_av:  unrecognized class 57

This is because the userspace components have not been updated yet -- the 
patch just went into -mm.

The workaround is to enable the old networking controls via the kernel 
parameter selinux_compat_net=1.  Once the distro packages have been 
updated, this will not be necessary.  All that's needed to start with in 
fact is a change to the startup scripts to do this at boot, depending on 
the package version.  This is a brief temporary issue in -mm.

> And I'd agree with the other commenters: if these features are compulsory
> for SELinux then we might as well just `select' them.  Right now it's way
> too hard.

Ok, I'll look into selecting them.

> Even if we do that, the chances of people actually going off and finding
> all the other random secmark Kconfig options and turning on the appropriate
> ones seem pretty small.  Needs a rethink.  Perhaps a standalone secmark
> menu, or just selecting everything..
> 
> And maybe just remove all the various netfilter secmark CONFIG options
> altogether and make all the new code dependent upon the top-level
> CONFIG_SECMARK.

I'm not sure what you mean here.  The top level secmark just enables the 
skb->secmark field without adding any mechanism to use it.  Then, two 
mechanisms which have been provided (the SECMARK and CONNSECMARK) targets 
can be independently enabled.  These are not the only possible ways of 
utilizing skb->secmark, so these components are configurable separately.



- James
-- 
James Morris
<jmorris@namei.org>
