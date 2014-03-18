From: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Subject: Re: [PATCH] phy: micrel: add of configuration for LED mode
Date: Tue, 18 Mar 2014 16:56:06 +0100
Message-ID: <6677304.0KbXKA76PZ@avalon>
References: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk> <20140227091505.GA6945@e106331-lin.cambridge.arm.com> <530F13DB.90009@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"linux-kernel-81qHHgoATdFT9dQujB1mzip2UmYkHbXO@public.gmane.org"
	<linux-kernel-81qHHgoATdFT9dQujB1mzip2UmYkHbXO@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ben Dooks <ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <530F13DB.90009-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Ben,

A bit of a late reply, I had missed this patch, sorry.

On Thursday 27 February 2014 10:30:51 Ben Dooks wrote:
> On 27/02/14 09:15, Mark Rutland wrote:
> > On Wed, Feb 26, 2014 at 11:48:00AM +0000, Ben Dooks wrote:
> >> Add support for the led-mode property for the following PHYs
> >> which have a single LED mode configuration value.
> >> 
> >> KSZ8001 and KSZ8041 which both use register 0x1e bits 15,14 and
> >> KSZ8021, KSZ8031 and KSZ8051 which use register 0x1f bits 5,4
> >> to control the LED configuration.
> >> 
> >> Signed-off-by: Ben Dooks <ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
> >> ---
> >> 
> >>  Documentation/devicetree/bindings/net/micrel.txt | 18 +++++++++
> >>  drivers/net/phy/micrel.c                         | 49 ++++++++++++++++--
> >>  2 files changed, 63 insertions(+), 4 deletions(-)
> >>  create mode 100644 Documentation/devicetree/bindings/net/micrel.txt
> >> 
> >> diff --git a/Documentation/devicetree/bindings/net/micrel.txt
> >> b/Documentation/devicetree/bindings/net/micrel.txt new file mode 100644
> >> index 0000000..98a3e61
> >> --- /dev/null
> >> +++ b/Documentation/devicetree/bindings/net/micrel.txt
> >> @@ -0,0 +1,18 @@
> >> +Micrel PHY properties.
> >> +
> >> +These properties cover the base properties Micrel PHYs.
> >> +
> >> +Optional properties:
> >> +
> >> + - micrel,led-mode : LED mode value to set for PHYs with configurable
> >> LEDs.
> >> +
> >> +              Configure the LED mode with single value. The list of PHYs
> >> and
> >> +	      the bits that are currently supported:
> >> +
> >> +	      KSZ8001: register 0x1e, bits 15..14
> >> +	      KSZ8041: register 0x1e, bits 15..14
> >> +	      KSZ8021: register 0x1f, bits 5..4
> >> +	      KSZ8031: register 0x1f, bits 5..4
> >> +	      KSZ8051: register 0x1f, bits 5..4
> >> +
> >> +              See the respective PHY datasheet for the mode values.
> > 
> > What do these mean, roughly,, and why can the kernel not decide how to
> > cnofigure these?
> 
> Board specific, in the case of the Lager one of the LEDs is connected
> to the ethernet mac block to indicate link, however the default mode
> is not for just "Link" so we have to change it.
> 
> > In general we prefer to not place raw register values in the DT, and I'd
> > like to know why we'd have to here.
> 
> I could copy out stuff from the data-sheet, but I was trying to avoid a
> copy and paste job.

I quite agree with Mark here, I would prefer not to list register values in DT 
bindings. However, the hardware hardware diversity doesn't help us abstracting 
LED modes.

The following table summarizes LED usage options.

Device              Mode   LED usage
-----------------------------------------------------------------------------
8001 (LED[3:0])     00     Collision / Full-Duplex / Speed / Link/Activity
                    01     Activity / Full-Duplex/Collision / Speed / Link
                    10     Activity / Full-Duplex / 100Mbps Link / 10Mbps Link
                    11     Reserved
80[23]1 (LED[0])    00     Link/Activity
                    01     Link
                    10     Reserved
                    11     Reserved
80[45]1 (LED[1:0])  00     Speed / Link/Activity
                    01     Activity / Link
                    10     Reserved
                    11     Reserved

While LED mode could be described by LED0 mode using "link-activity" or "link" 
strings for the 80[2345]1 chips, the 8001 makes that slightly more complex and 
shows that future chips might not conform to any scheme we come up with now.

I thus have no strong preference for a string-based mode description over 
using an integer. However, if we keep the integer value, I wouldn't use the 
register value directly, but would instead use the mode field value as an 
integer in the 0-3 range. This would remove knowledge of the PHY control 
register layout from the DT node content, and bring more consistency to the 
values.

Mark, what's your opinion on this ? I know that David has already applied the 
patch to his tree, but we can still fix this before v3.16. I can submit a 
patch.

-- 
Regards,

Laurent Pinchart

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
