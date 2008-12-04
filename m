From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [E1000-devel] networking probs in next-20081203
Date: Thu, 04 Dec 2008 13:11:20 -0500
Message-ID: <1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
References: <20081203171834.86903d39.akpm@linux-foundation.org>
	 <20081204151436.GA18783@x200.localdomain> <49381644.8020502@intel.com>
	 <20081204175236.GA19808@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	ebiederm@xmission.com, James Morris <jmorris@namei.org>,
	Eric Paris <eparis@parisplace.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zombie2.ncsc.mil ([144.51.88.133]:42766 "EHLO zombie2.ncsc.mil"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbYLDSOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 13:14:31 -0500
In-Reply-To: <20081204175236.GA19808@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-12-04 at 20:52 +0300, Alexey Dobriyan wrote:
> On Thu, Dec 04, 2008 at 09:41:24AM -0800, Kok, Auke wrote:
> > Alexey Dobriyan wrote:
> > > On Wed, Dec 03, 2008 at 05:18:34PM -0800, Andrew Morton wrote:
> > >> x86_64, CONFIG_E1000E=y.
> > >>
> > >> Current Linus mainline is OK, but with linux-next I'm seeing the following:
> > >>
> > >> - During boot I see a "cannot open /proc/net/dev" fly past.  But when
> > >>   it gets to the login prompt, I can read /proc/net/dev.
> > > 
> > > I _suspect_ it might me something with /proc/net changes (again) and initcall
> > > ordering.
> > > 
> > > Andrew, as rejectless quick test, you can do
> > > 
> > > 	git checkout -f 26b0d981e7dd1d5b4852ed5719bd1388c7994163	# sic
> > > 
> > > which is the last tree merged before proc tree in that next tree.
> > > 
> > >> - Networking won't come up.  `ifup eth0' says "determining ip address
> > >>   ...  failed", and the failure is immediate.
> > >>
> > >> - eth0 appears in the ifconfig oputput as normal - it just won't come up.
> > >>
> > >> - nothing interesting in dmesg
> > >>
> > >>
> > >> Here's the dmesg: http://userweb.kernel.org/~akpm/dmesg-dead-net.txt
> > >> (that dmesg was generated with E1000=y, E1000E=y, but that doesn't seem
> > >> to matter)
> > >>
> > >> The .config: http://userweb.kernel.org/~akpm/config-dead-net.txt
> > 
> > perhaps this line has something to do with it?
> > 
> > [   50.539326] type=1400 audit(1228348149.537:4): avc:  denied  { mount } for
> > pid=11636 comm="ifconfig" name="/" dev=proc/net ino=4026531842
> > scontext=system_u:system_r:ifconfig_t:s0 tcontext=system_u:object_r:unlabeled_t:s0
> > tclass=filesystem

The significant line from the dmesg output is this:
[   32.113405] SELinux: initialized (dev proc/net, type proc/net), not configured for labeling

> Of course!
> 
> > maybe try disabling selinux?
> 
> This will work. :^)

SELinux didn't change here.  /proc/net did.

-- 
Stephen Smalley
National Security Agency

