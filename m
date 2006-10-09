From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [patch 5/5] d80211: allow wireless vlan interface to have sameMAC an AP interface
Date: Mon, 9 Oct 2006 14:38:07 -0700
Message-ID: <20061009213807.GH26254@instant802.com>
References: <20061003181118.537800000@devicescape.com> <20061003181233.GE19403@devicescape.com> <1160343128.4701.6.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-66.dex002.intermedia.net ([64.78.20.24]:48722 "EHLO
	DHOST002-66.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751569AbWJIViN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 17:38:13 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1160343128.4701.6.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 08, 2006 at 11:32:08PM +0200, Johannes Berg wrote:

> Hm. Now I finally understand the vlan interface type. Neat. How do you
> bind stas to one vlan interface? Is it possible to do on the fly after
> EAP or similar?

Yes, I just merged in support for this (dynamic VLANs) into hostapd.
RADIUS Access-Accept is used select VLAN is being used and the STA is
bound at that point to another virtual interface, if needed.

> Anyway. Wouldn't it make more sense to not even allow setting a MAC
> address different from all AP interfaces, i.e. require that the VLAN
> interface have the same MAC as one of the AP interfaces that exist?

That would be fine, too, but maybe not necessary.

> And then there probably should be a check that prohibits binding a sta
> to a vlan interface that has a different MAC than the AP interface it
> is/was on... or something.

Well, that would probably be correct for most (all?) cases, but then
again, I would probably not bother with this level of validation in
kernel. Whatever is taking care of binding the STA in user space (e.g.,
hostapd) can do the validation.

-- 
Jouni Malinen                                            PGP id EFC895FA
