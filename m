From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking (WEXT events and 64/32 compat)
Date: Wed, 17 Sep 2008 13:11:33 -0700 (PDT)
Message-ID: <20080917.131133.135282530.davem@davemloft.net>
References: <20080908.204323.04156464.davem@davemloft.net>
	<20080909040525.GA26151@hostap.isc.org>
	<20080917191128.GA23239@hostap.isc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jouni.malinen@atheros.com, alex.williamson@hp.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: j@w1.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752454AbYIQULp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 16:11:45 -0400
In-Reply-To: <20080917191128.GA23239@hostap.isc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jouni Malinen <j@w1.fi>
Date: Wed, 17 Sep 2008 12:11:28 -0700

> Would it be acceptable to ever enable use of IWEVASSOCREQIE /
> IWEVSSOCRESPIE in kernel if the workaround were available in new
> wpa_supplicant versions? Or should we try to add a new WEXT event
> type that uses fixed size for the length field and then replace the old
> IWEVCUSTOM with the new type since IWEVCUSTOM does not work with
> 64/32-bit case (wpa_supplicant just knows how to avoid processing that
> bogus event data)?

Moving to a new event with a strictly sized datastructure, instead of
one that has variable sized members like pointers and crap which are
impossible to compat layer'ify, is indeed my preference.

But in that case, we might as well make nl80211 usable instead.

We'll always have those existing wpa_supplicant binaries out there, we
can't break them.  And the size checks wpa_supplicant makes is a BOGUS
and REDICULIOUS way to get these malformed objects "supported" and
"usable".
