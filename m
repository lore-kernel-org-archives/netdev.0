From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH wireless-dev] d80211: Switch d80211_mgmt.h to ieee80211.h style definitions
Date: Mon, 7 Aug 2006 10:20:50 -0700
Message-ID: <20060807172050.GH4702@instant802.com>
References: <200608050145.40137.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Linville <linville@tuxdriver.com>, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-1.dex002.intermedia.net ([64.78.21.6]:41769 "EHLO
	dhost002-1.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932239AbWHGRU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 13:20:58 -0400
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200608050145.40137.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 05, 2006 at 01:45:33AM -0700, Michael Wu wrote:
> d80211: Switch d80211_mgmt.h to ieee80211.h style definitions
> 
> This patch switches a number of defines in d80211_mgmt.h to enums taken from 
> ieee80211.h and makes the corresponding changes in net/d80211.

>  include/net/d80211_mgmt.h  |  153 
>  net/d80211/ieee80211.c     |    2 -
>  net/d80211/ieee80211_sta.c |   50 +++++++-------


Is this really needed? Based on the changes here, these are mostly used
internally in net/d80211/ieee80211_sta.c and not in other parts of the
tree. In addition, I would actually like to see ieee80211_sta.c be made
mostly obsolete with a user space implementation of client MLME (e.g.,
the one in wpa_supplicant which is based on this ieee80211_sta.c file).

Changing WLAN_STATUS_* and WLAN_REASON_* to be enum's while keeping
their old names is fine. However, I would rather not change the names of
the information element IDs (WLAN_EID_*) into MFIE_TYPE_*. What is that
'MFIE' anyway? Management Frame IE? These IEs are not limited to
management frames..

In other words, I would skip all the changes into ieee80211_sta.c and
would only change d80211_mgmt.h to use enum's with old names.

-- 
Jouni Malinen                                            PGP id EFC895FA
