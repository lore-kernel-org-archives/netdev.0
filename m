From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH 4/5] d80211: Switch d80211 to IEEE80211_ style names
Date: Fri, 4 Aug 2006 12:20:40 -0700
Message-ID: <20060804192040.GA10764@instant802.com>
References: <20060801211530.150852000.midnight@suse.cz> <20060801191659.59FED483A8@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-2.dex002.intermedia.net ([64.78.21.14]:13515 "EHLO
	dhost002-2.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1161377AbWHDTUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 15:20:46 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060801191659.59FED483A8@silver.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 09:16:59PM +0200, Jiri Benc wrote:
> From: Michael Wu <flamingice@sourmilk.net>
> This patch switches the WLAN_ definitions in d80211.h to IEEE80211_ style
> definitions found in ieee80211.h. It also switches to MAC_ARG and MAC_FMT.

This kind of change is more than just search-and-replace since frame
type and subtype macros were using different style (not shifted left in
WLAN_FC_{TYPE,STYPE}_* and shifted left in IEEE80211_{FTYPE,STYPE}_*.
Some of these seemed to be caught in the patch, but not all. At least
the following changes look incorrect. I'm not sure whether this is a
complete list of issues, though, so going through all IEEE80211_STYPE_*
and IEEE80211_FTYPE_* cases again could be a worthwhile exercise.


ieee80211.c:
-		if (WLAN_FC_GET_STYPE(fc) & 0x08)
+		if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_QOS_DATA)
  (this is supposed to catch all QoS frames, not just QoS data subtype) 

ieee80211.c:
-			fc |= WLAN_FC_STYPE_QOS_DATA << 4;
+			fc |= IEEE80211_STYPE_QOS_DATA << 4;

ieee80211.c:
-			fc &= ~(WLAN_FC_STYPE_QOS_DATA << 4);
+			fc &= ~(IEEE80211_STYPE_QOS_DATA << 4);

wme.c:
-	qos = fc & (WLAN_FC_STYPE_QOS_DATA << 4);
+	qos = fc & (IEEE80211_STYPE_QOS_DATA << 4);

-- 
Jouni Malinen                                            PGP id EFC895FA
