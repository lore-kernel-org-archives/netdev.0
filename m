From: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH V11 2/4] ptp: Added a clock that uses the eTSEC found on
 the MPC85xx.
Date: Wed, 23 Feb 2011 13:24:44 -0600
Message-ID: <20110223132444.65dfdda4@schlenkerla>
References: <cover.1298447722.git.richard.cochran@omicron.at>
	<be1f5e801e8cd0145dd23aadae7c2055bb3c1d47.1298447722.git.richard.cochran@omicron.at>
	<20110223165058.GE14597@angua.secretlab.ca>
	<20110223112612.30071995@schlenkerla>
	<20110223175459.GH14597@angua.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	<linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	<linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110223175459.GH14597-MrY2KI0G/OVr83L8+7iqerDks+cytr/Z@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Feb 2011 10:54:59 -0700
Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org> wrote:

> On Wed, Feb 23, 2011 at 11:26:12AM -0600, Scott Wood wrote:
> > eTSEC is versioned, that's more reliable than the chip name since chips
> > have revisions (rev 2.1 of mpc8313 has eTSEC 1.6, not sure about previous
> > revs of mpc8313).  Logic blocks can be and have been uprevved between one
> > revision of a chip to the next.  I think "fsl,mpc8313rev2.1-etsec-ptp"
> > would be taking things a bit too far (and there could be board-level bugs
> > too...).
> > 
> > If you really need to know the exact SoC you're on, look in SVR (which
> > will provide revision info as well).  Isn't the device tree for things that
> > can't be probed?
> 
> This is far more about the binding than it is about the chip revision.
> When documenting a binding it makes far more sense to anchor it to a
> specific implementation than to try and come up with a 'generic'
> catchall.

Whatever string is used should be written into a binding document.

fsl,etsec-v1.6-ptp seems like it would be just as good for that purpose.

Even just fsl,etsec-ptp will identify the binding, though it's lacking in
identifying the hardware (in the absence of access to the eTSEC ID
registers).

If somehow Freescale makes something completely different in the future
called "etsec-ptp", then we'll just have to pick a different name for
*that* compatible (after we smack whoever was responsible for reusing the
name).  The point of the vendor namespacing is to constrain this problem to
a manageable scope.

> > The eTSEC revision is probeable as well, but due the way PTP is described as
> > a separate node, the driver doesn't have straightforward access to those
> > registers.
> 
> Ignorant question: Should the ptp be described as a separate node?

Probably not.

> > Insisting on an explicit chip also encourages people to claim compatibility
> > with that chip without ensuring that it really is fully compatible.
> 
> In practise, I've not seen this to be an issue.

I see it often enough in our BSPs (though the BSP device trees tend to be
problematic in a variety of ways), especially on things like guts and
pmc.

It's a question of how strong a statement people are asked to make -- in a
place where fixing errors is somewhat painful, and we don't really need that
strong statement of compatibility to be made, as long as there's another
way to fully identify the hardware (e.g. SVR, top-level board compatible) if
some strange workaround needs to be made[1].

To turn things around, in practice, I've not seen compatibles that don't
encode a specific chip name to be a problem, as long as it's well
documented what it means.

-Scott

[1] IIRC, this was the original reason for citing a specific chip, but it
doesn't hold up if that chip gets cited by other chips as compatible.  If
compatibliity includes having all the same bugs, then very little will be
able to claim compatibility, and we'll be back to long lists of device
IDs in the driver.  Not to mention errata that are discovered after a
device tree claiming compatibility is released...
