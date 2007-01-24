From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 24 Jan 2007 13:26:38 -0200
Message-ID: <20070124152638.GC3036@dmt.poa.virtua.com.br>
References: <20070116185524.GA5681@dmt> <20070117141103.0e468bf4@griffin.suse.cz> <1169046072.2750.10.camel@localhost.localdomain> <1169047134.9175.49.camel@johannes.berg> <1169055788.2550.44.camel@localhost.localdomain> <1169056847.2550.56.camel@localhost.localdomain> <20070117230945.GB9387@infradead.org> <45AEAEEB.6050603@pobox.com> <20070118082250.GE11056@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dcbw@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jiri Benc <jbenc@suse.cz>, Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:54877 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752050AbXAXR2i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 12:28:38 -0500
Content-Disposition: inline
In-Reply-To: <20070118082250.GE11056@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 18, 2007 at 03:22:50AM -0500, John W. Linville wrote:
> On Wed, Jan 17, 2007 at 06:19:07PM -0500, Jeff Garzik wrote:
> > Christoph Hellwig wrote:
> > >On Wed, Jan 17, 2007 at 01:00:47PM -0500, Dan Williams wrote:
> 
> > >>allows the 8388 to continue routing other laptops' packets over the mesh
> > >>*while the host CPU is asleep*.
> > >
> > >We're not going to put a lot of junk into the kernel just because the OLPC
> > >folks decide to do odd powermanagment schemes.
> > 
> > We're not going to ignore useful power management schemes just because 
> > they don't fit neatly into a pre-existing category.
> > 
> > I think the request to determine how all this maps into MLME is fair, 
> > though.
> 
> Definitely.  Also, I wonder if there was any attempt to evaluate how
> the ieee80211 (or d80211) code might be extended in order to elimnate
> the need for some of the libertas wlan_* files?

The regulatory domain structures, channel information (struct
ieee80211_channel), HW mode (struct ieee80211_hw_mode) compromised of
supported channels and rates, and probably a few others in the same
category. I can't see the possibility of using d80211 as it stands
(designed for softmac cards dealing with 802.11 packets to/from the OS).

However, it does not make any sense to use the structures defined by
d80211 if not effectively using it (we send/receive 802.3 frames to the
firmware, after all), IMO.

As discussed on this thread, there is a lot of code to be cleanup up,
but no structural changes AFAICT. Is there a general agreement on that,
now?

