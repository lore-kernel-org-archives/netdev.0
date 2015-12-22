From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next 2/3] tcp: send_reset: test for non-NULL sk first
Date: Tue, 22 Dec 2015 22:46:32 +0100
Message-ID: <5679C4B8.5010204@stressinduktion.org>
References: <1450729766-14926-1-git-send-email-fw@strlen.de>
 <1450729766-14926-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:56587 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933232AbbLVVqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:46:35 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id C205A20D95
	for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 16:46:34 -0500 (EST)
In-Reply-To: <1450729766-14926-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.12.2015 21:29, Florian Westphal wrote:
> tcp_md5_do_lookup requires a full socket, so once we extend
> _send_reset() to also accept timewait socket we would have to change
> 
> if (!sk && hash_location)
> 
> to something like
> 
> if ((!sk || !sk_fullsock(sk)) && hash_location) {
>   ...
> } else {
>   (sk && sk_fullsock(sk)) tcp_md5_do_lookup()
> }
> 
> Switch the two branches: check if we have a socket first, then
> fall back to a listener lookup if we saw a md5 option (hash_location).
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
