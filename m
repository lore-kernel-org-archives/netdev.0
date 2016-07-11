From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Mon, 11 Jul 2016 09:32:05 -0400
Message-ID: <e8f7a166-0624-b6d5-6937-67d9397c915e@stressinduktion.org>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
 <20160705130327.GA10737@breakpoint.cc> <20160705170541.3f210675@pixies>
 <20160709090020.GB2067@breakpoint.cc> <20160709153017.791f2607@halley>
 <20160709132230.GD2067@breakpoint.cc> <20160710105120.72d80371@pixies>
 <20160711081511.GG2067@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, shmulik.ladkani@gmail.com,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Florian Westphal <fw@strlen.de>,
	Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:56501 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752831AbcGKNcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 09:32:08 -0400
In-Reply-To: <20160711081511.GG2067@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.07.2016 04:15, Florian Westphal wrote:
> Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:
>> OK with the general idea; However I don't want to abuse IPSKB_FORWARDED
>> as the skb is not really "ip forwarded", and it might have undesirable
>> affects, such as in 'ip_skb_dst_mtu' which follows.
> 
> I don't see a problem with that. Hannes?

If we segment/fragment along the way we need to use the
non-pmtu/interface-mtu, so this change would be correct in regard to the
mtu selection.

Bye,
Hannes
