From: "Tomas Winkler" <tomasw@gmail.com>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 22:26:31 +0300
Message-ID: <1ba2fa240808271226i95a7789k481a68b09dc60164@mail.gmail.com>
References: <20080827013009.GA15781@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	"Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.184]:38483 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbYH0T0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 15:26:33 -0400
Received: by gv-out-0910.google.com with SMTP id e6so6774gvc.37
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 12:26:31 -0700 (PDT)
In-Reply-To: <20080827013009.GA15781@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> John W. Linville (1):
>      mac80211: quiet chatty IBSS merge message

This patch is correct yet it suppresses an important warning, meaning
that you have constant IBSS reconnection, remove all connected station
and adding them again, This greatly degraded performance. This is
caused by inability to adjust to TSF of the IBSS leader

<snipt>
static int ieee80211_sta_join_ibss(struct net_device *dev,
				   struct ieee80211_if_sta *ifsta,
				   struct ieee80211_sta_bss *bss)
.....
/* Remove possible STA entries from other IBSS networks. */
	sta_info_flush_delayed(sdata);
</snip>

> Assaf Krauss (1):
>      iwlwifi: W/A for the TSF correction in IBSS
>

This patch fixes this problem in iwlwifi

We've observed same problem with the broadcom card

Tomas
