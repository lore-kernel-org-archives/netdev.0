From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH net-next] myri10ge: allow per-board firmware overriding
Date: Sat, 18 Apr 2009 22:36:39 -0400
Message-ID: <1240108599.5342.11.camel@obelisk.thedillows.org>
References: <49E7239B.4000309@myri.com>
	 <20090417095038.49b745bf@dhcp-lab-109.englab.brq.redhat.com>
	 <49EA1DAC.1000602@myri.com>
	 <1240102617.5342.6.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:34364 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753105AbZDSCgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Apr 2009 22:36:44 -0400
In-Reply-To: <1240102617.5342.6.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-04-18 at 20:56 -0400, David Dillow wrote:
> On Sat, 2009-04-18 at 20:36 +0200, Brice Goglin wrote:
> > Stanislaw Gruszka wrote:
> >
> > > This would help in situation like this - admin will not have to thinking
> > > about boards initialization ordering. Besides some other drivers (like MTD
> > > cmd partitions) use own parsing for similar things, I think would be
> > > nice to unify things. What You think?
> > >   
> > 
> > We actually thought about supporting "eth2:fwname1,eth0:fwname2". But it
> > might be hard to implement in this case due to udev possible renaming
> > interfaces and this firmware names being needed *before* the renaming.
> > So yes, an automatic way to handle such parameter strings might be good,
> > but maybe not in this exact case.
> 
> It seems like this could be done in user space, using the PCI bus ID as
> a key to select the firmware. The uevent identifies which device is
> requesting the firmware, so some modification to /lib/udev/firmware.sh
> should do it.

On further inspection, that should work on Fedora 10, and it looks like
other distros that use the upstream udev rules. RHEL5 uses a binary
helper, so changing 05-early-rules.sh to use a script similar to udev's
firmware.sh would work. YMMV elsewhere, those are the ones I had handy
and happened to be working on some udev rules.

Dave

