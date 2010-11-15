From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] UDEV - Add 'udevlom' command line param to
 start_udev
Date: Mon, 15 Nov 2010 17:16:39 +0000
Message-ID: <1289841399.2586.18.camel@bwh-desktop>
References: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com>
	 <20101103180500.GA7441@kroah.com>
	 <20101105025848.GA14021@pws490.domsch.com>
	 <20101115164714.GB7030@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, "K, Narendra" <Narendra_K@Dell.com>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>
To: Matt Domsch <Matt_Domsch@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20101115164714.GB7030@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-11-15 at 10:47 -0600, Matt Domsch wrote:
> On Thu, Nov 04, 2010 at 09:58:48PM -0500, Matt Domsch wrote:
> > On Wed, Nov 03, 2010 at 11:05:00AM -0700, Greg KH wrote:
> > > On Wed, Nov 03, 2010 at 10:25:25PM +0530, Narendra_K@Dell.com wrote:
> > > > Hello,
> > > > 
> > > > This patch allows users to specify if they want the onboard network
> > > > interfaces to be renamed to lomN by implementing a command line param
> > > > 'udevlom'.
> > > 
> > > Ick ick ick.
> > > 
> > > Why not do this in some other configuration file?  Don't rely on udev
> > > being started with a different option, that is only ripe for abuse by
> > > everyone else who wants their pet-project to get into the udev
> > > environment.
> > > 
> > > Please, surely there's a different way to do this.
> > 
> > At Linux Plumbers Conference today, this problem space was discussed
> > once again, and I believe concensus on approach was reached.  Here
> > goes:
> > 
> > * If a 70-persistent-net.rules file sets a name, honor that.  This
> >   preserves existing installs.
> > 
> > * If BIOS provides indexes for onboard devices, honor that.
> > ** Rename onboard NICs "lom[1-N]" as BIOS reports (# matches chassis labels)
> > ** No rename for all others "ethX" (no change for NICs in PCI slots/USB/others)
> 
> I'm getting a lot of pushback from Dell customers on our
> linux-poweredge mailing list (thread starts [1]) that the choice of
> name "lomX" is poor, due to HP's extensive use of LOM meaning Lights
> Out Management, rather than my intended meaning of "LAN on
> Motherboard".  Gotta hate TLA collisions.
> 
> So, I'm open to new ideas for naming these.  At LPC, Ted noted that
> 2- and 3-letter names are expected.  "nic[1234]" or "en[1234]" ?
[...]

I would suggest avoiding "nic" since some people use "NIC" to mean
specifically an add-in card rather than LOM.  In addition there is some
ambiguity with multi-port cards/controllers of whether NIC means a
controller or a port.

Other options for the prefix:
- "lan".  Maybe too generic.
- "mbe" = MotherBoard Ethernet. Looks a bit like "GbE" as some OEMs put
on the port labels.
- "eom" = Ethernet On Motherboard

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

