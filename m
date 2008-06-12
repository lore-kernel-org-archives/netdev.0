From: Luis Carlos Cobo <luisca@cozybit.com>
Subject: Re: [RFC] Do not activate promiscuous mode on wlan interfaces for
	bridging.
Date: Thu, 12 Jun 2008 11:19:53 -0700
Message-ID: <1213294793.6615.16.camel@localhost>
References: <1213232760.6645.24.camel@localhost>
	 (sfid-20080612_030607_332834_1EFDE126)  <1213255570.3871.8.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, shemminger@linux-foundation.org,
	j@w1.fi, bridge@linux-foundation.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:31994 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbYFLST4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 14:19:56 -0400
Received: by wa-out-1112.google.com with SMTP id j37so2988614waf.23
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 11:19:55 -0700 (PDT)
In-Reply-To: <1213255570.3871.8.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-06-12 at 09:26 +0200, Johannes Berg wrote:
> All your description makes a lot of sense, but I don't see why altering
> the bridge code is necessary. In mac80211, we decided that the "promisc"
> bit only means to capture all frames in the current BSS (remember that
> in ethernet there is no way to capture frames from different LAN
> segments) and hence an AP would not behave differently in promisc mode
> at all since, by definition, it sees all BSS traffic.

You are right, within the BSS every frame is going to be addressed to
the AP anyway, so we should not receive more or less frames when
activating promiscuous mode.

When activating promiscuous mode in this device, it stops acknowledging
frames, and this impairs the association process. The other solution
would be to ignore the promiscuous mode commands (i.e. never send the
command to the device) for interfaces in AP mode. If this is the only
device showing this behavior, maybe that would be the best solution.

-- 
Luis Carlos Cobo Rus       GnuPG ID: 44019B60
cozybit Inc.


