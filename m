From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Thu, 3 Jul 2008 22:52:36 +0200
Message-ID: <200807032252.37992.rjw@sisk.pl>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org> <92840.1215113467@turing-police.cc.vt.edu> <1215114540.10393.659.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, Theodore Tso <tytso@mit.edu>,
	Jeff Garzik <jeff@garzik.org>, Hugh Dickins <hugh@veritas.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:43955 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbYGCUuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 16:50:37 -0400
In-Reply-To: <1215114540.10393.659.camel@pmac.infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 3 of July 2008, David Woodhouse wrote:
> On Thu, 2008-07-03 at 15:31 -0400, Valdis.Kletnieks@vt.edu wrote:
> > On Thu, 03 Jul 2008 19:56:02 BST, David Woodhouse said:
> > 
> > > They had to 'make oldconfig' and then actually _choose_ to say 'no' to
> > > an option which is fairly clearly documented, that they are the
> > > relatively unusual position of wanting to have said 'yes' to. You're
> > > getting into Aunt Tillie territory, when you complain about that.
> > 
> > Note that some of us chose 'no' because we *thought* that we already *had*
> > everything in /lib/firmware that we needed (in my case, the iwl3945 wireless
> > firmware and the Intel cpu microcode).  The first that I realized that
> > the tg3 *had* firmware was when I saw the failure message, because before
> > that, the binary blob was inside the kernel.  And then, it wasn't trivially
> > obvious how to get firmware loaded if the tg3 driver was builtin rather
> > than a module.
> > 
> > And based on some of the other people who apparently got bit by this same
> > exact behavior change on this same exact "builtin but no firmware in kernel"
> > config with this same exact driver, it's obvious that one of two things is true:
> > 
> > 1) Several of the highest-up maintainers are Aunt Tillies.
> > or
> > 2) This is sufficiently subtle and complicated that far more experienced
> > people than Aunt Tillie will Get It Very Wrong.
> 
> Not really. It's just a transitional thing. As you said, you know
> perfectly well that modern Linux drivers like iwl3945 handle their
> firmware separately through request_firmware() rather than including it
> in unswappable memory in the static kernel. We're just updating some of
> the older drivers to match.
> 
> I've often managed to configure a kernel which doesn't boot, when I've
> updated and not paid attention to the questions which 'oldconfig' asks
> me. It's fairly easy to do. But I don't advocate that 'allyesconfig'
> should be the default, just in case someone needs one of the options...
> 
> But as I said, I'm content to let Linus make that decision. In the
> meantime, I'd prefer to get back to the simple business of updating
> drivers to use request_firmware() as they should, and have maintainers
> actually respond to the _patches_ rather than refusing to even look at
> the code changes because they disagree with the default setting for the
> CONFIG_FIRMWARE_IN_KERNEL option.

Hm, well, but if the driver in question is in a module, then whether or not
this option is set really doesn't matter, does it?

Rafael
