From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/6] flow_dissector: Add hash_extra field to
 flow_keys struct
Date: Sun, 01 Mar 2015 13:27:45 -0800
Message-ID: <1425245265.5130.88.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
	 <1425093109-1077-4-git-send-email-therbert@google.com>
	 <1425109054.5130.77.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150228203119.GA7687@breakpoint.cc>
	 <CA+mtBx8zP0rDG1Dh=KcG0t5dqaqnqS+8---4SBvLD_jGpgue2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38395 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbbCAV1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 16:27:48 -0500
Received: by igbhl2 with SMTP id hl2so12660770igb.3
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 13:27:47 -0800 (PST)
In-Reply-To: <CA+mtBx8zP0rDG1Dh=KcG0t5dqaqnqS+8---4SBvLD_jGpgue2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-03-01 at 09:55 -0800, Tom Herbert wrote:

> Alternatively, I think we might be able to eliminate the use of
> flow_keys and flow_dissect from the qdisc code altogether. It looks
> like this is only being used to determine a hash over the addresses,
> ports, and protocol so I am thinking that we can just call
> skb_get_hash for that. Will try to post some patches soon.

Note that SFQ only stored the keys in case of a potential rehash,
and because skb->cb[] was available then.

As the rehash implies to _not_ use skb_get_hash() it is simply better to
recompute the flow key from packet, in the unlikely case we do have a
rehash.

Rehashing SFQ adds reorders, so people should think twice before using
it.
