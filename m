From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Mon, 14 Mar 2005 16:32:22 -0800
Message-ID: <200503150032.j2F0WRDD011602@guinness.s2io.com>
References: <42362232.4070202@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid@neterion.com>, <alex@neterion.com>,
        "'David S. Miller'" <davem@davemloft.net>
To: "'Jeff Garzik'" <jgarzik@pobox.com>, "'Andi Kleen'" <ak@muc.de>
In-Reply-To: <42362232.4070202@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com]
> Sent: Monday, March 14, 2005 3:46 PM
> To: Andi Kleen
> Cc: Leonid Grossman; netdev@oss.sgi.com; leonid@neterion.com;
> alex@neterion.com; David S. Miller
> Subject: Re: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE
> Adapters
> 
> Andi Kleen wrote:
> > "Leonid Grossman" <leonid.grossman@neterion.com> writes:
> >
> >>Do you have other objections to the submission? We'd like to see if
> these
> >>could be addressed; going forward we see significant benefits both for
> >>S2io/Neterion (and our customers) and for community to use this driver.
> >
> >
> > I guess the main objection to the HAL comes not from performance
> > issues (Usually the only thing that really counts for performance
> > is data cache misses and the HAL is unlikely to affect this much), but
> > the coding style etc.. Indeed it does not look too Linux like.
> 
> Well, not coding style, but code analysis and maintenance issues.
> 
> HALs are generally type-opaque, breaking checker-style tools and sparse
> checks.
> 
> "it looks like Linux code" has implications on bug finding and fixing,
> and long term maintenance of the code.  You want to make it easy for
> someone to make the same change across N net drivers.
> 
> Because most ->hard_start_xmit() hooks were written in a similar
> fashion, it was easy and quick to deploy fixes for the skb_padto()
> security bug across many net drivers.
> 
> A lot of tiny costs that mostly wind up as noise:  additional branching
> / derefs.
> 
> My biggest objection is that HALs increase the overall "cost" of
> maintaining a piece of code, and serve as a barrier against outside
> (non-primary-author) kernel hacker involvement.

There are several valid arguments against HAL-based MAC drivers, but the
maintenance cost is probably one of the main arguments in the "for" column.

My assumption is that the vast majority of the maintenance for the
hw-dependent code will be done by Neterion team - and for us the HAL-based
approach allows to fix a bug or to add a new feature in hw-dependent code
once and for all across all drivers. In our experience, third-party
contribution tends to come to the OS-specific part of the driver not to the
HAL - but if there is a meaningful contribution to the HAL from one of our
Unix driver, it will be useful to pick it up in a transparent fashion. 

Agreed that HAL makes code analysis and changes by the outside hacker
somewhat more difficult - but hopefully not by much, and again I expect most
of the outside contribution to be done above HAL level.
Also, we are trying to ease the pain by releasing HAL API and ASIC
Programming Manual documentation.

> 
> Remember, this driver is going to be with us for -10- years or more.

Yes, and this was actually a second reason for the submission. Present
"s2io" driver is fine for the current and next ASIC, beyond that we will
have to probably re-write it anyways. The new submission is 2+ years
"younger" and has a much better chance to require an incremental upgrade
only. Since 10GbE is just taking off and not a lot of people got familiar
with the code, we feel it's easier to take this hit earlier than later. 

To sum it up, I agree that HAL is a trade-off - but for this hardware it has
been working well for us in multi-platform environment; the hope is that you
will find a (smaller, perhaps) subset of these benefits useful in Linux
environment as well.

Leonid

> 
> 	Jeff
> 
