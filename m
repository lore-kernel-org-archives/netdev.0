From: Jouni Malinen <jkm@devicescape.com>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Thu, 16 Nov 2006 09:21:31 -0800
Message-ID: <20061116172131.GA7404@instant802.com>
References: <20061023145646.32bbd59f@griffin.suse.cz> <1161678053.7083.7.camel@devlinux-hong> <1161678908.2840.12.camel@ux156> <1161679134.7258.6.camel@devlinux-hong> <1161681021.2840.23.camel@ux156> <1161764889.8668.13.camel@devlinux-hong> <1161766245.2767.17.camel@ux156> <1163470978.7789.31.camel@devlinux-hong> <1163607901.2705.53.camel@ux156> <1163670762.2763.19.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hong Liu <hong.liu@intel.com>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Simon Barber <simon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-97.dex002.intermedia.net ([64.78.19.89]:5313 "EHLO
	DHOST002-97.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1161361AbWKPR1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 12:27:20 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1163670762.2763.19.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 16, 2006 at 10:52:42AM +0100, Johannes Berg wrote:

> I think we should simplify the stack code by making it have *only* the
> distinction between between hardware and software crypto (on a per-key
> basis).

Hmm.. I think I need to see the patch for doing this before being able
to decide whether I'd like this or not.. Michael MIC is a bit
unfortunate design since it happens at MSDU, not MPDU level. Because of
this, most hardware designs have to do something special when
fragmentation is used. If the fragmentation is done in the stack, it may
be difficult to move the Michael MIC operations into the driver since
they need to happen before fragmentation (which would be done in the
stack in this case)..

Other than this special case, it sounds reasonable to keep most of the
small hardware design changes hidden in the driver code as long as the
functions that are exported from the stack are the same ones that the
stack would be using anyway (i.e., not having to maintain two versions
of the same code).

-- 
Jouni Malinen                                            PGP id EFC895FA
