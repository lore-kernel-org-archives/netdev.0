From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Mon, 6 Nov 2006 21:01:45 +0100
Message-ID: <20061106210145.6824bec6@griffin.suse.cz>
References: <1162741174.24574.22.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:36242 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1753048AbWKFUBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 15:01:49 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1162741174.24574.22.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 05 Nov 2006 16:39:34 +0100, Johannes Berg wrote:
> 003-d80211-cookie.patch
>    d80211: change the cookie to be opaque
> 
>    This changes the 'cookie' that d80211 returns from alloc_hw
>    to be an opaque value to the driver. Turned out that it wasn't
>    such a great idea but since it was generally a clean up I kept
>    this patch to base my other patches on.

ACK.

> 005-d80211-reduce-mdev-1.patch
> 006-d80211-reduce-mdev-2.patch
>    d80211: reduce mdev usage
> 
>    These two patches reduce mdev madness and change a lot of functions
>    to take a struct ieee80211_local * instead of the master netdev

ACK.

> 007-d80211-cleanup-rxmgmt.patch
>    d80211: reduce mdev usage, fix ieee80211_rx_mgmt
> 
>    Cleans up the ieee80211_rx_mgmt and related code

Looks good after a quick look. Need to review it more deeply.

> 008-d80211-scan-sanity.patch
>    d80211: reduce master ieee80211_ptr deref in scan routines
> 
>    Similar to the reduce mdev patches, just for the scan routines

ACK.

> 009-d80211-convert-spaces.patch
>    d80211: convert leading spaces to tabs
> 
>    I hated working on the code, so I did this. The next patch
>    breaks everything anyway.

NAK. There are too many patches pending. Let's do this just before
merging.

> 010-d80211-proto.patch
>    d80211: convert to an 802.11 protocol
> 
>    Converts d80211 to be a protocol together with tons of
>    cleanups and more. Hard to describe in two lines.

NAK.

This is too big patch for a review, it does too much things and I
fundamentally disagree with some parts of the patch. Split it into
individual patches.

Just some things which are broken with the patch (the list is probably
not complete):

> * The mdev no longer has a sub_if_data attached (why ever did it??)
>   It's private area is for the driver since we don't create it but
>   the driver does. I did keep the notation of mdev/master all through,
>   but it's no longer the stacks device. Keep that in mind.

This definitely breaks AP mode. In the code, there is heavily (ab)used
the fact that the master device is in fact an AP device. I tried to fix
that but it was so difficult I gave up. It is needed to rewrite the
whole RX path (and even that is probably not enough). As this will
be fixed for free when we have native 802.11 devices, I don't think we
need to do anything about it now.

> * sysfs layout changed. There is no wiphy or an ieee80211 class any more,
>   the attributes that used to be there are now in the net_device that
>   the driver registered, and our attributes are below the devices we created.

You want an ieee80211 class. Once you get rid of a master interface you
need something with per-hardware information, statistics etc.

> * sysfs layout changed. There is no wiphy or an ieee80211 class any more,
>   the attributes that used to be there are now in the net_device that
>   the driver registered, and our attributes are below the devices we created.

Doesn't belong to this patch.

> And probably lots more.

???


What did happen with
d80211: add a function to get the wiphy index
d80211: add a perm_addr hardware property
d80211: add a struct device* hardware property
d80211: add a ethtool_ops hardware property
patches?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
