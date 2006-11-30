From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.19-rc6-mm2: uli526x only works after reload
Date: Wed, 29 Nov 2006 18:18:09 -0800
Message-ID: <20061129181809.c55da5e8.akpm@osdl.org>
References: <20061128020246.47e481eb.akpm@osdl.org>
	<200611300008.21434.rjw@sisk.pl>
	<20061129152619.0d1ac361.akpm@osdl.org>
	<200611300204.16507.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, tulip-users@lists.sourceforge.net,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Valerie Henson <val_henson@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:32955 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S936127AbWK3CSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 21:18:32 -0500
To: "Rafael J. Wysocki" <rjw@sisk.pl>
In-Reply-To: <200611300204.16507.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Nov 2006 02:04:15 +0100
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> > > 
> > > git-netdev-all.patch
> > > git-netdev-all-fixup.patch
> > > libphy-dont-do-that.patch
> > 
> > Are you able to eliminate libphy-dont-do-that.patch?
> > 
> > > Is a broken-out version of git-netdev-all.patch available from somewhere?
> > 
> > Nope, and my few fumbling attempts to generate the sort of patch series
> > which you want didn't work out too well.  One has to downgrade to
> > git-bisect :(
> > 
> > What does "doesn't work" mean, btw?
> 
> Well, it turns out not to be 100% reproducible.  I can only reproduce it after
> a soft reboot (eg. shutdown -r now).
> 
> Then, while configuring network interfaces the system says the interface name
> is ethxx0, but it should be eth1 (eth0 is an RTL-8139, which is not used).  Now
> if I run ifconfig, it says:
> 
> eth0: error fetching interface information: Device not found
> 
> and that's all (normally, ifconfig would show the information for lo and eth1,
> without eth0).  Moreover, 'ifconfig eth1' says:
> 
> eth1: error fetching interface information: Device not found
> 
> Next, I run 'rmmod uli526x' and 'modprobe uli526x' and then 'ifconfig' is
> still saying the above (about eth0), but 'ifconfig eth1' seems to work as
> it should.  However, the interface often fails to transfer anything after
> that.

Lovely.  Sounds like some startup race, perhaps against userspace.

Is CONFIG_PCI_MULTITHREAD_PROBE set?  (err, we meant to disable that for
2.6.19 but forgot).

