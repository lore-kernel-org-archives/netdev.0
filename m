From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Mon, 14 Mar 2005 22:02:23 -0800
Message-ID: <200503150602.j2F62ODD027579@guinness.s2io.com>
References: <bd1c90987d5e22481f0fa2ac3f63ced3@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid@neterion.com>,
        "'Jeff Garzik'" <jgarzik@pobox.com>
To: "'Scott Feldman'" <sfeldma@pobox.com>, <alex@neterion.com>
In-Reply-To: <bd1c90987d5e22481f0fa2ac3f63ced3@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Scott Feldman [mailto:sfeldma@pobox.com]
> Sent: Monday, March 14, 2005 9:15 PM
> To: <alex@neterion.com>
> Cc: <netdev@oss.sgi.com>; <leonid@neterion.com>; 'Jeff Garzik'
> Subject: Re: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE
> Adapters
> 
> 
> On Mar 14, 2005, at 12:22 PM, Alex Aizman wrote:
> 
> > HAL-based
> > =========
> > Most Neterion drivers are HAL (Hardware Abstraction Layer) based. This
> > is
> > always a curse and blessing; in our experience this was the latter by
> > a big
> > margin. While the current "s2io" driver in the kernel doesn't share
> > HAL code
> > with other driver, the "xge" driver is HAL-based.
> 
> e1000 and ixgb are HAL-based, which is why there is always push back
> when someone in the community modifies *_hw.[ch].  I'd hate to see more
> of this in the kernel, but I can definitely relate to the "testing
> across multiple OSes" gain.

I'll be thrilled to see meaningful community changes to xge HAL files :-)

> 
> Here's an (old?) idea: remember the NDIS-wrapper project?  I think the
> reverse is much more interesting.  A linux-wrapper takes a plain old
> Linux driver and wraps it with what ever is needed to make it an NDIS
> driver.  Or FreeBSD, or whatever.  Let's pretend this is trivial for a
> second.  What do we gain?  1) one clean Linux driver to maintain, 2)
> testability on other OSes, and 3) access to other OSes' certification
> kits.  Licensing is clean: the Linux driver is GPL and the
> linux-wrapper code is GPL.  Can't the world revolve around Linux and
> let everyone else be burdened with the abstraction layer overhead?

Believe or not, something like this could (and has been) done but did not
stick. People did even spookier things, like a wrapper on top of another OS
binary driver - some of you guys may remember Novell NLM vs. Unixware driver
project :-)

These attempts were always short-lived, my guess is because the teams behind
the project did not have a long-term motivation and/or the expertise to get
it done and (more importantly) to maintain the framework, as OS driver
models evolved and diverged.

On the other hand, the HAL model is more alive than ever - Intel, Neterion
and many/most other modern NICs I'm aware of use HAL approach. 
This is actually much more common between non-Linux Oses, since there are
still significant (warranted or not) GPL-related concerns. 

HAL discussion is an old one indeed, and the truth is still in the eye of a
beholder :-)

People who are sorely responsible for supporting multiple OS drivers for the
same hardware (that is, NIC vendors) have strong bias in favor of HAL
approach, for all the right reasons (mainly, maintainability and support). 

People who are sorely responsible for supporting drivers for multiple NICs
on the same OS have strong bias against HAL approach - also for some pretty
valid reasons.

Linux is one (but not the only) case when the drivers are maintained by both
groups, and the biases/preferences collide...

Interestingly enough, as time goes by and everybody is getting thin on
resources, HAL approach tends to gain "marketshare" rather fast - at
present, Linux "s2io" is one of the very few Neterion drivers that is not
using HAL.


> 
> -scott
