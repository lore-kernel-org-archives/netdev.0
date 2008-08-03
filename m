From: Brice Goglin <brice.goglin@labri.fr>
Subject: Re: [PATCH 11/31]: net: Implement simple sw TX hashing.
Date: Sun, 03 Aug 2008 14:35:46 +0200
Message-ID: <4895A622.4080104@labri.fr>
References: <20080717.051635.124264554.davem@davemloft.net> <4895A19B.5090307@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:39553 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009AbYHCMfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Aug 2008 08:35:51 -0400
In-Reply-To: <4895A19B.5090307@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> So I wonder if we shouldn't change all this into:
> 1) simple_tx_hash(skb) returns a big protocol-independent integer (like
> a concatenation or basic xor of IP proto/addr/...). It basically just
> converts the skb header in something flat and proto-independent.
> 2.a) if the device provides select_queue(), we pass this integer to it.
> select_queue() either uses the skb headers if it really wants to hash IP
> or IPv6 precisely, or uses our protocol-independent integer and just
> hash it in a dumb way without caring about the protocol hidden behind it.
> 2.b) if there's no select_queue(), we hash the big integer depending on
> the number of tx queues
>   

Or (easier) just export simple_tx_hash() to modules so that drivers can
rely on it to hash protocols that they have no clue about?

Brice

