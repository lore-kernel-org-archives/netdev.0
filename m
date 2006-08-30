From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH] d80211: use list_for_each_entry{,_safe}
Date: Wed, 30 Aug 2006 08:43:22 -0700
Message-ID: <20060830154322.GA18041@instant802.com>
References: <1156927420.4013.57.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-44.dex002.intermedia.net ([64.78.21.135]:55052 "EHLO
	dhost002-44.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751055AbWH3Pnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 11:43:32 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1156927420.4013.57.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2006 at 10:43:39AM +0200, Johannes Berg wrote:
> This patch converts uses of list_for_each and list_for_each_safe to
> list_for_each_entry and list_for_each_entry_safe respectively where
> applicable. It also adds locking in some places though I'm not entirely
> sure that I can do it that way (i.e. call ieee80211_key_enable_hwaccel
> etc. with spinlocks held).

Could you please separate cleanup parts (list_for_each changes) from
functional changes (adding locking) to make it easier to review the
patch?

I would prefer not to hold spinlocks when calling registered callbacks
from the hardware driver. At minimum, this would need to be documented
very clearly to make sure that whoever is writing low-level drivers
would be aware of this. In general, it would just be simpler if this can
be avoided altogether.

-- 
Jouni Malinen                                            PGP id EFC895FA
