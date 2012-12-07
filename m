From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH] af_packet: don't to defrag shared skb
Date: Fri, 07 Dec 2012 22:41:42 +0100
Message-ID: <1354916502.9124.18.camel@jlt4.sipsolutions.net>
References: <1354906561-4695-1-git-send-email-eric@regit.org>
	 <20121207.153134.25835204617509469.davem@davemloft.net>
	 <1354915824.9124.11.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_223020_561049_DB965D43)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric@regit.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:58745 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932126Ab2LGVlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 16:41:21 -0500
In-Reply-To: <1354915824.9124.11.camel@jlt4.sipsolutions.net> (sfid-20121207_223020_561049_DB965D43)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-07 at 22:30 +0100, Johannes Berg wrote:

> The only other theory I can come up with right now is that the skb_get()
> happens in deliver_skb via __netif_receive_skb. Keeping in mind that
> wpa_supplicant might have another packet socket open for authentication
> packets, that seems like a possibility. I'll test it once I figure out
> how to do this "defrag" option you speak of :)

Hmm now I'm venturing into the unknown (for me) and realm of
speculation...

wpa_supplicant opens a packet socket for ETH_P_EAPOL, which indirectly
eventually calls dev_add_pack(). But if you do the same for another
socket, you'll get the same again, and then deliver_skb() will deliver
only a refcounted packet to the prot_hook->func().

This seems like it could very well cause the problem?

johannes
