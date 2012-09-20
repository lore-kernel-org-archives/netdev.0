From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 14:35:24 +0200
Message-ID: <1348144524.4161.26.camel@jlt4.sipsolutions.net>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	 <1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	 <1347631355.5263.19.camel@sauron.fi.intel.com>
	 <1347640763.5263.24.camel@sauron.fi.intel.com>
	 <1347892887.7112.9.camel@sauron.fi.intel.com>
	 <1348142775.2388.10.camel@sauron.fi.intel.com>
	 (sfid-20120920_140144_429034_0B789F16)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: artem.bityutskiy@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:48651 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553Ab2ITMeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 08:34:50 -0400
In-Reply-To: <1348142775.2388.10.camel@sauron.fi.intel.com> (sfid-20120920_140144_429034_0B789F16)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> >             56138f5 iwlwifi: dont pull too much payload in skb head
> >             3edaf3e mac80211: manage AP netdev carrier state
> 
> The second patch (AP carrier state) actually exposed a connman issue
> which I fixed and submitted a connman patch:
> http://lists.connman.net/pipermail/connman/2012-September/011232.html
> 
> However, Eric's patch still causes tethering problems to me.


Let me recap a bit. Artem is using connman, which sets up the wifi
interface as part of a bridge. It runs wpa_supplicant to create an AP
(only AP and mesh mode interfaces can be bridged anyway).


Eric, you said:

> I would say some part of the stack assumes a header (I dont know wich
> one ?) is pulled in skb->head/data, and thats a bug.
> 
> Always use pskb_may_pull(skb, XXX) to make sure you can access XXX
> bytes in skb->data

I thought we'd figure out which part of the stack assumes a header, so I
asked Artem to test a one-line patch which adds "skb_linearize()" before
"netif_receive_skb()" in mac80211. This makes it work, but I'm not sure
where after that the bad assumption might be.

johannes
