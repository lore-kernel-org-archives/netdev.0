From: James Morris <jmorris@namei.org>
Subject: Re: [PATCHSET 0/7] SECMARK 2.0
Date: Sun, 21 May 2006 23:21:28 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605212308240.20759@d.namei>
References: <Pine.LNX.4.64.0605180458130.569@d.namei> <20060521165435.7cafbc7c.akpm@osdl.org>
 <Pine.LNX.4.64.0605212237160.20595@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, kaber@trash.net, sds@tycho.nsa.gov,
	netdev@vger.kernel.org, kmacmillan@tresys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:57308 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964986AbWEVDVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 May 2006 23:21:30 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605212237160.20595@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 21 May 2006, James Morris wrote:

> > And I'd agree with the other commenters: if these features are compulsory
> > for SELinux then we might as well just `select' them.  Right now it's way
> > too hard.
> 
> Ok, I'll look into selecting them.

There are several problems with this.  Because SELinux can only be 
selected as Y, using select for the secmark modules would force them also 
be be built statically into the kernel.  Another issue is the presence of 
new and old Netfilter infrastructure, and there's no way the SELinux 
config can know whether to enable the new generic NF conntrack system or 
the old IP conntrack one.  Then, there's the issue of forcing a specific 
configuration on the user: perhaps they don't want connection tracking at 
all and just want static controls (i.e. only use the SECMARK target, not 
CONNSECMARK).  And how far do you go?  Force the selection of FTP 
connection tracking?  What about new conntrack targets?

The only reasonable solution is to allow the user to configure what they 
need, with the simplest case being that only NETWORK_SECMARK is enabled as 
a minimum requirement for SELinux, which will result in all traffic 
carying the default 'unlabeled_t' marking, which thye user then needs to 
have an appropriate policy for.

I was planning on posting detailed documentation on the new secmark scheme 
once it was in -mm, and having selinux_compat_net=1 as a stopgap until 
people either know what to configure or their distro userland is updated.  
(Support for secmark controls cannot be rolled out into distros until the 
kernel infrastructure is in an upstream kernel such as -mm).


- James
-- 
James Morris
<jmorris@namei.org>
