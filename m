From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [take3 0/5] d80211: remove bitfields from include/net/d80211.h
Date: Wed, 25 Oct 2006 12:17:02 -0700
Message-ID: <20061025191702.GA32410@devicescape.com>
References: <20061025184244.GA30046@devicescape.com> <20061025190129.GH19513@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:39075 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S964813AbWJYTRK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 15:17:10 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20061025190129.GH19513@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2006 at 03:01:29PM -0400, Jeff Garzik wrote:
> On Wed, Oct 25, 2006 at 11:42:44AM -0700, David Kimdon wrote:
> > Continue d80211 bitfield removal.  In general, compilers have
> > difficulty generating efficient code for bitfields.  This patchset
> > removes all bitfields from include/net/d80211.h.
> > 
> > I converted the 1 bit bitfields into a bit in a u32/u16 or u8 flags
> > structure member.  Larger bitfields I converted into their
> > u8/u16/whatever equivalent.
> 
> For bit flags, usually it is best to use up to 32 bits of an
> unsigned long, which guarantees that you use a machine integer for
> all platforms.

That is how I originally had the patch, but then had a question about
increasing structure size so I dropped flags to u16 or u8 for
structures that were made larger by the bitfield removal.

For the key_conf bitfields size doesn't matter much.  For the tx_control
bitfields size matters a bit more since it is needed per-packets and
dirvers currently need to store a copy to pass to the tx complete
handler.

Thoughts?

David
