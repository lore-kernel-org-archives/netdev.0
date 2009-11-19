From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] macvlan: Reflect macvlan packets meant for other
 macvlan devices
Date: Thu, 19 Nov 2009 15:47:55 +0100
Message-ID: <4B055A9B.1090502@trash.net>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <200911182332.56309.arnd@arndb.de> <m1bpiz8k1x.fsf@fess.ebiederm.org> <200911191244.43916.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick Mullaney <pmullaney@novell.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44070 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699AbZKSOrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 09:47:51 -0500
In-Reply-To: <200911191244.43916.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> On Thursday 19 November 2009, Eric W. Biederman wrote:
>>> It seems that we should never drop dst then. We either forward the frame to
>>> netif_rx or to dev_queue_xmit, and from how I read it now, we want to keep
>>> the dst in both cases.
>> When we loop back on our selves we certainly need to have dst clear because
>> we don't know how to cache routes through multiple network namespaces.
> 
> Ah, right. So should I add the explicit dst_drop to the new dev_forward_skb()
> then? The veth driver doesn't need it, but it also looks like it won't hurt.

Yes, I think that should be fine.
