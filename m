From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Thu, 18 Jan 2007 10:40:17 -0500
Message-ID: <1169134818.2788.13.camel@localhost.localdomain>
References: <20070116185524.GA5681@dmt>
	 <20070117141103.0e468bf4@griffin.suse.cz>
	 <1169046072.2750.10.camel@localhost.localdomain>
	 <1169047134.9175.49.camel@johannes.berg>
	 <1169055788.2550.44.camel@localhost.localdomain>
	 <1169056847.2550.56.camel@localhost.localdomain>
	 <20070117230945.GB9387@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jiri Benc <jbenc@suse.cz>, Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752037AbXARPkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 10:40:43 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20070117230945.GB9387@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-17 at 23:09 +0000, Christoph Hellwig wrote:
> On Wed, Jan 17, 2007 at 01:00:47PM -0500, Dan Williams wrote:
> > Furthermore, I might add that the entire reason this part was chosen for
> > OLPC was because it _is_ fullmac.
> > 
> > To drive down power consumption, the OLPC puts the host CPU to sleep but
> > keeps the 8388 powered on.  That consumes around 400mW max.  But it
> > allows the 8388 to continue routing other laptops' packets over the mesh
> > *while the host CPU is asleep*.
> 
> We're not going to put a lot of junk into the kernel just because the OLPC
> folks decide to do odd powermanagment schemes.

Nor are we going to try to push highly OLPC-specific changes into this
driver in a non-modular manner.  This chip is also used in, for example,
the X-Box 360 wireless dongle, and other non-OLPC people are working on
adding support for the 8385 SDIO/CF variant.

It would be arrogant of us to think that the driver would _just_ be
useful for OLPC, and that's why nobody ever said that it was going to be
an OLPC specific driver, not I, nor Marcelo.  Give us some credit here
before you start jumping all over something neither of us have said or
implied.

If we do make any OLPC specific changes (there are currently none [1]),
they will be properly abstracted, conditionalized, and/or generalized.
We will not be throwing random crap into this driver.

Cheers,
Dan

[1] The code for the 802.11s mesh interface is in the driver, but that
will/should automatically turn itself off if the firmware doesn't
support that functionality.  Furthermore, none of the mesh bits are
OLPC-specific and may be used with any platform on which the driver
runs.

