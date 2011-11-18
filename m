From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: Bug#645308: tg3 broken for NetXtreme 5714S in squeeze 6.0.3
 installer
Date: Fri, 18 Nov 2011 11:54:35 -0800
Message-ID: <20111118195435.GA31807@mcarlson.broadcom.com>
References: <1318901100.3340.36.camel@deadeye>
 <20111018142056.GF29261@torres.zugschlus.de>
 <1319084914.23980.96.camel@deadeye>
 <20111021090046.GA13930@torres.zugschlus.de>
 <20111021090811.GA5993@torres.zugschlus.de>
 <1319199579.2918.42.camel@deadeye>
 <20111024212409.GA29764@mcarlson.broadcom.com>
 <1319500074.31243.47.camel@deadeye>
 <20111026002032.GA31575@mcarlson.broadcom.com>
 <1319614904.11727.17.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"645308@bugs.debian.org" <645308@bugs.debian.org>,
	"Marc Haber" <mh+debian-bugs@zugschlus.de>,
	netdev <netdev@vger.kernel.org>
To: "Ben Hutchings" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1492 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755993Ab1KRTxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Nov 2011 14:53:45 -0500
In-Reply-To: <1319614904.11727.17.camel@deadeye>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2011 at 12:41:44AM -0700, Ben Hutchings wrote:
> On Tue, 2011-10-25 at 17:20 -0700, Matt Carlson wrote:
> > On Mon, Oct 24, 2011 at 04:47:54PM -0700, Ben Hutchings wrote:
> > > On Mon, 2011-10-24 at 14:24 -0700, Matt Carlson wrote:
> > > > On Fri, Oct 21, 2011 at 05:19:39AM -0700, Ben Hutchings wrote:
> > > > > On Fri, 2011-10-21 at 11:08 +0200, Marc Haber wrote:
> > > > > > On Fri, Oct 21, 2011 at 11:00:46AM +0200, Marc Haber wrote:
> > > > > > > On Thu, Oct 20, 2011 at 05:28:34AM +0100, Ben Hutchings wrote:
> > > > > > > > I don't see any changes that would obviously change the way this device
> > > > > > > > is reconfigured during a down/up cycle.  There were some changes to
> > > > > > > > power management that should just let the PCI core do some work that the
> > > > > > > > driver used to, but it's possible that the result isn't quite the same.
> > > > > > > > I built a module with those reverted; source and binary attached.  Could
> > > > > > > > you test that?  I checked that d-i does include an insmod command.
> > > > > > > 
> > > > > > > The squeeze 6.0.3 installer with the shipped tg3.ko replaced with
> > > > > > > yours boots and networks just fine without any workaround and without
> > > > > > > manual interaction.
> > > > > > 
> > > > > > I was a bit fast on that. The interface now fails right in the middle
> > > > > > of installation and needs the modprobe -r, modprobe stunt to network
> > > > > > again.
> > > > > 
> > > > > Matt, Michael,
> > > > > 
> > > > > The tg3 driver has regressed for the 5714S since Linux 2.6.32.  Marc
> > > > > Haber found this in the backported version included in our stable
> > > > > update, but also confirmed it in Linux 3.0.
> > > > > 
> > > > > Bringing the interface down and then up again (which the installer does
> > > > > for some reason) can leave it unable to pass traffic (possibly after
> > > > > working for a few packets) until the module is reloaded.
> > > > > 
> > > > > I asked Marc to check whether reverting the power management changes
> > > > > (071697e2bcd8dff2af4d6fdd6525c2324f89553b,
> > > > > d237d9ecf06a00f0ebca657958cf2a1e92940796) made a difference, but it
> > > > > doesn't seem to.
> > > > > 
> > > > > There is more information in the bug log at
> > > > > <http://bugs.debian.org/645308>.
> > > > 
> > > > Where can I get the sources for this driver?  Commit
> > > > 9e975cc291d80d5e4562d6bed15ec171e896d69b, entitled
> > > > "tg3: Fix io failures after chip reset" has been a common source of
> > > > problems.
> > > 
> > > Our current package has Linux 3.0.6 which includes the backport of that
> > > change.  However, it is *not* included in my backport to 2.6.32 so it
> > > doesn't explain the original report.
> > > 
> > > The backported version can be found in:
> > > 
> > > git://anonscm.debian.org/kernel/linux-2.6.git squeeze
> > 
> > The kernel version of that repository is 3.0.0-rc1.  Am I looking in the
> > right place?
> 
> Look at the squeeze branch, not master.
> 
> Ben.
> 
> > But you're right.  The version of the driver in that repository does not
> > have the change.

O.K.  With Ben's help, I was able to see the diff between the two
driver versions.

I think I misspoke earlier.  The commit I mentioned above fixes a problem
introduced in an earlier patch.  (commit ID
d2394e6bb1aa636f3bd142cb6f7845a4332514b5, entitled
"tg3: Always turn on APE features in mac_mode reg")  So the fact that
2.6.32-35 works and 2.6.32-36 doesn't means you applied the problematic
patch that had the bug, but you didn't apply the above fix to correct it.

Sorry for the confusion.
