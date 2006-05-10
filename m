From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH wireless-dev] d80211: Add support for user space clientMLME
Date: Wed, 10 May 2006 10:17:49 -0700
Message-ID: <20060510171749.GH23571@instant802.com>
References: <20060502211817.GA30842@instant802.com> <20060503182815.1a9ebb5e@griffin.suse.cz> <20060503164458.GB10524@instant802.com> <1146745613.1137.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-25.dex002.intermedia.net ([64.78.21.107]:10270 "EHLO
	dhost002-25.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965007AbWEJRRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 13:17:53 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1146745613.1137.28.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 04, 2006 at 02:26:53PM +0200, Johannes Berg wrote:
> On Wed, 2006-05-03 at 09:44 -0700, Jouni Malinen wrote:
> > But there is.. I committed changes to the wpa_supplicant devel branch
> > for this yesterday. It seems to work fine with net/d80211 and bcm43xx
> > with this small patch to d80211 to allow the functionality to be moved
> > into user space.
> 
> Cool, do you have a list of things that we need to support for it to
> work on a 'softmac' based driver (iow removing softmac in favour of
> this)?

This is still somewhat open, but at minimum, there needs to be a
mechanism for receiving and sending management frames from user space.
d80211 uses a "management netdev" for this currently (the same one that
was used before with hostapd for AP mode). In addition to that,
wpa_supplicant expect to be able to read list of support channels and TX
rates (get_hw_feature_data handler in driver wrapper) and to be able to
add and remove STA entries (e.g., for TX rate control and association
status validation in kernel code).

Currently, scanning is done simply by setting the channel with
SIOCSIWFREQ and listening for management frames. However, the goal is to
provide simple atomic operations that user space programs can request
the kernel code to do. This would cover not only scanning, but also some
other needs like IEEE 802.11k radio measurements. These operations could
be something like "stop transmit, move to channel 5, report received
management frames, record noise level, do this for 5 ms, return to
operational channel, enable transmit".

-- 
Jouni Malinen                                            PGP id EFC895FA
