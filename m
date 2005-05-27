From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 27 May 2005 13:27:04 -0700
Message-ID: <Pine.CYG.4.58.0505271305590.2148@mawilli1-desk2.amr.corp.intel.com>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
 <20050527085055.79da3d75@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Ronciak, John" <john.ronciak@intel.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>,
        hadi@cyberus.ca, Robert.Olsson@data.slu.se
In-Reply-To: <20050527085055.79da3d75@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Stephen, Robert, and Jamal all replied to my original message, and all
said approximately the same thing:  "Why don't you just reduce the weight
in the driver?  It does the same thing."

To which I reply, respectfully, I know that.  And no it doesn't, not
exactly.

My primary reason for adding this setting is to allow for runtime tweaking
-- just like max_backlog has right now.  Driver weight is a compile-time
setting, and has to be changed for every driver that you run.

This setting allows you to scale the weight of all your drivers, at
runtime, in one place.  It's complimentary to Stephen's max_weight idea --
his patch affects how long you spend in any individual softirq; my patch
affects how long you spend in any driver's individual NAPI poll routine,
as well as how long the softirq lasts.

Perhaps we can merge the two patches to come up with some Ultimate
Tweakable Network Goodness.  I'd be happy to do that (on Tuesday; I'm
heading home early today) if anybody's interested.

-Mitch

NB:
I've got a white paper that I wrote up for internal consumption.  I plan
to post it to our Sourceforge archive, but I need to do a bunch of
scrubbing first, lest our lawyers go into convulsions.

Meanwhile, I can give away the ending:  for my performance tests, on a
pure Gigabit network, I saw consistently better performance by a) using my
patch, b) reducing max_backlog, and c) using a nonzero value for
packet_weight.
