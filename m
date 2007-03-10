From: Michael Buesch <mb@bu3sch.de>
Subject: Re: SSB/b44 build failure
Date: Sat, 10 Mar 2007 20:27:25 +0100
Message-ID: <200703102027.25759.mb@bu3sch.de>
References: <1173496449.13449@shark.he.net> <20070310150346.GB5062@tuxdriver.com> <20070310180541.GA17160@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Randy Dunlap <rdunlap@xenotime.net>, bunk@stusta.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:50709
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbXCJT2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 14:28:30 -0500
In-Reply-To: <20070310180541.GA17160@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 10 March 2007 19:05, Christoph Hellwig wrote:
> On Sat, Mar 10, 2007 at 10:03:46AM -0500, John W. Linville wrote:
> > FWIW, this is coming from the port of b44 to use the SSB bus which
> > I'm carrying in the wireless-dev tree.
> > >
> > SSB (i.e. "Sonics Silicon Backplane") is a bus used in Broadcom SoCs
> > including the b44 and bcm43xx hardware.  The SSB bus driver and the
> > b44 port to SSB is being developed by Michael Buesch, the maintainer of
> > the bcm43xx driver.  I've been carrying the b44 SSB port in my tree for
> > Michael's convenience.  Just an FYI for those wondering what SSB is...
> 
> Btw, what's the reason this is in wireless-dev?  Could we please merge
> this code into mainline soonish (aka 2.6.22) instead of interwinding
> it with totally unrelated wireless changes?

nono, don't. SSB is still in heavy development and this would
slow it down by magnitudes.
The reason it's in wireless-dev is, because b44-ssb is simply just
a "sideeffect" of ssb. ssb is mainly written for bcm43xx. That
b44 also has a ssb bus is cool, so it can re-use the code. But
there's _no_ reason to get ssb mainline without bcm43xx going
mainline, too. b44-mainline does not depend on ssb. Current mainline
has the ssb code built into b44. The b44 port in wireless-dev just rips
that code out and uses the ssb subsystem (so it also adds
a few features to b44. For example the ability to dump and write
the EEPROM).

It's really helpful to have the development of b44-ssb in
wireless-dev, because there still are heavy changes in ssb.
Being required to merge a ssb change through mainline before
I can implement a new feature (or fix a bug) in bcm43xx-dev is just
not acceptable.

The _final_ merging is another story. I think a few days before
wireless-dev is merged mainline ssb and b44-ssb should be merged
mainline seperately. Just to make it clear that these are not
wireless related. (ssb is not wireless related, too. Strictly said).

Short: "totally unrelated wireless changes" is a false statement ;)

-- 
Greetings Michael.
