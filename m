From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH 1/1] UDEV - Add 'udevlom' command line param to start_udev
Date: Mon, 15 Nov 2010 10:47:14 -0600
Message-ID: <20101115164714.GB7030@auslistsprd01.us.dell.com>
References: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com> <20101103180500.GA7441@kroah.com> <20101105025848.GA14021@pws490.domsch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "K, Narendra" <Narendra_K@Dell.com>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:38259 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932132Ab0KOQrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 11:47:16 -0500
Content-Disposition: inline
In-Reply-To: <20101105025848.GA14021@pws490.domsch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 04, 2010 at 09:58:48PM -0500, Matt Domsch wrote:
> On Wed, Nov 03, 2010 at 11:05:00AM -0700, Greg KH wrote:
> > On Wed, Nov 03, 2010 at 10:25:25PM +0530, Narendra_K@Dell.com wrote:
> > > Hello,
> > > 
> > > This patch allows users to specify if they want the onboard network
> > > interfaces to be renamed to lomN by implementing a command line param
> > > 'udevlom'.
> > 
> > Ick ick ick.
> > 
> > Why not do this in some other configuration file?  Don't rely on udev
> > being started with a different option, that is only ripe for abuse by
> > everyone else who wants their pet-project to get into the udev
> > environment.
> > 
> > Please, surely there's a different way to do this.
> 
> At Linux Plumbers Conference today, this problem space was discussed
> once again, and I believe concensus on approach was reached.  Here
> goes:
> 
> * If a 70-persistent-net.rules file sets a name, honor that.  This
>   preserves existing installs.
> 
> * If BIOS provides indexes for onboard devices, honor that.
> ** Rename onboard NICs "lom[1-N]" as BIOS reports (# matches chassis labels)
> ** No rename for all others "ethX" (no change for NICs in PCI slots/USB/others)

I'm getting a lot of pushback from Dell customers on our
linux-poweredge mailing list (thread starts [1]) that the choice of
name "lomX" is poor, due to HP's extensive use of LOM meaning Lights
Out Management, rather than my intended meaning of "LAN on
Motherboard".  Gotta hate TLA collisions.

So, I'm open to new ideas for naming these.  At LPC, Ted noted that
2- and 3-letter names are expected.  "nic[1234]" or "en[1234]" ?

And yes, they'd prefer that we keep "eth[0123]" for the onboard
devices, but I simply don't see how to do that without kernel changes,
due to the races in both naming them in the kernel vs udev renaming,
and simple races between two udev processes.

Thanks,
Matt

[1] http://lists.us.dell.com/pipermail/linux-poweredge/2010-November/043576.html

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
