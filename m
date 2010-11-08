From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH 1/1] UDEV - Add 'udevlom' command line param to start_udev
Date: Mon, 8 Nov 2010 12:17:49 -0600
Message-ID: <20101108181749.GA31046@auslistsprd01.us.dell.com>
References: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com> <20101103180500.GA7441@kroah.com> <20101105025848.GA14021@pws490.domsch.com> <AANLkTin_rswTZn5RxH375u4xsoftQzMSPMRfUvy77fdX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, "K, Narendra" <Narendra_K@dell.com>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@dell.com>,
	"Rose, Charles" <Charles_Rose@dell.com>
To: Sujit K M <sjt.kar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:56065 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621Ab0KHSRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 13:17:53 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTin_rswTZn5RxH375u4xsoftQzMSPMRfUvy77fdX@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 08, 2010 at 02:12:56PM +0530, Sujit K M wrote:
> > At Linux Plumbers Conference today, this problem space was discussed
> > once again, and I believe concensus on approach was reached. ?Here
> > goes:
> 
> Was the patch a starting point for the discussion.

The discussion has been ongoing for 3 years.  This patch was posted
just prior to the conversation at LPC, where aspects of this patch
(reading values from sysfs and using them, if present) were discussed
at length.  The patch itself will have to undergo some changes based
on the outcome of that discussion.

 
> > * If a 70-persistent-net.rules file sets a name, honor that. ?This
> > ?preserves existing installs.
> >
> > * If BIOS provides indexes for onboard devices, honor that.
> > ** Rename onboard NICs "lom[1-N]" as BIOS reports (# matches chassis labels)
> > ** No rename for all others "ethX" (no change for NICs in PCI slots/USB/others)
> >
> > * If neither are true, do not rename at all.
> 
> I would like to know what is the difference in the nomenclature for this.

LOM == "LAN on Motherboard", aka "Embedded NIC".  I'm not wedded to
using "lomX", but it can't be ethX, and it must be short, and that's
as good as anything.

 
> > * Implementation will be:
> > ** Udev rules to be included in upstream udev will read the index
> > ? value from sysfs (provided by SMBIOS 2.6 info on kernels >= 2.6.36,
> > ? PCI DSM info at some future point) if present, and rename LOMs
> > ? based on that index value. ?Distros will use these rules by default
> > ? (Ubuntu and Fedora maintainers on board with the concept; I have
> > ? not spoken with other distros yet.)
> > ** Legacy distros with older udev rules will invoke biosdevname on
> > ? kernels < 2.6.36 to get the same information, if present, and will
> > ? rename LOMs based on index value.
> 
> How will you manage these scenarios.

I've had conversations with the relevant maintainers of the subsystems
of each of the major distributions.  What else are you looking for please?

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
