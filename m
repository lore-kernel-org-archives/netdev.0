From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v4 1/3] can: kvaser_usb: Fix tx queue start/stop race
 conditions
Date: Sat, 14 Mar 2015 17:19:45 +0200
Message-ID: <20150314151945.GA18736@vivalin-002>
References: <20150226152011.GA6075@linux>
 <20150314130249.GA20796@linux>
 <55043A7E.7040001@pengutronix.de>
 <20150314143820.GA22071@linux>
 <55044C9F.2070105@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55044C9F.2070105@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 14, 2015 at 03:58:39PM +0100, Marc Kleine-Budde wrote:
> On 03/14/2015 03:38 PM, Ahmed S. Darwish wrote:
> >> Applied to can. This will go into David's net tree and finally into
> >> net-next. Then I'll apply patches 2+3. Nag me, if I forget about them ;)
> >>
> > 
> > Thanks! :-)
> > 
> > So if I've understood correctly, this patch will go to -rc5 and
> > the rest will go into net-next?
> > 
> > If so, IMHO patch #2 should also go to -rc5. I know it's usually
> > frowned up on to add further patches at this late -rc stage, but
> > here's my logic:
> > 
> > The original driver code just _arbitrarily_ assumed a MAX_TX_URB
> > value of 16 parallel transmissions. This value was chosen, it seems,
> > because the driver was heavily based on esd_usb2.c and the esd code
> > just did so :-(
> > 
> > Meanwhile, in the Kvaser hardware at hand, if I've increased the
> > driver's max parallel transmissions little above the recommended
> > limit reported by firmware, the firmware breaks up badly, reports a
> > massive list of internal errors, and the candump traces becomes
> > sort of an internal mess hardly related to the actual frames sent
> > and received.
> 
> In this particular hardware, what's the limit as reported by the firmware?
> 

48 max oustanding tx, which is quite big in itself it seems.

Other drivers in the tree range between 10 (Peak) and 20 tx (8dev).

> > In my case, I was lucky that the brand we own here (*) had a higher
> > max outstanding transmissions value than 16. But if there is hardware
> 
> Okay - higher.
> 
> > out there with a max oustanding tx support < 16 (#), such hardware
> > will break badly under a heavy transmission load :-(
> 
> I see.
> 
> If you add this motivation to the patch description and let the subject
> reflect that this is a "fix" or safety measure rather than a possible
> performance improvement, no-one will say anything against this patch :D
> 

True; I admit the "fix" part should've been clearer :-)

Will send a better worded commit message then.

Thanks a lot,
Darwish
