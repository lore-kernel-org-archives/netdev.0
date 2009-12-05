From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] inetpeer: optimizations
Date: Sat, 05 Dec 2009 22:29:49 +0100
Message-ID: <4B1AD0CD.4040407@gmail.com>
References: <4B1A4E07.4030804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:60511 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756741AbZLEVaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2009 16:30:18 -0500
Received: by bwz27 with SMTP id 27so2714347bwz.21
        for <netdev@vger.kernel.org>; Sat, 05 Dec 2009 13:30:23 -0800 (PST)
In-Reply-To: <4B1A4E07.4030804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 12/05/2009 01:11 PM:

> - Use atomic_dec_and_test() in inet_putpeer()

atomic_dec_and_lock()?

>   This takes/dirties the lock only if necessary.
...

>  void inet_putpeer(struct inet_peer *p)
>  {
> -	spin_lock_bh(&inet_peer_unused_lock);
> -	if (atomic_dec_and_test(&p->refcnt)) {
> -		list_add_tail(&p->unused, &unused_peers);
> +	local_bh_disable();
> +	if (atomic_dec_and_lock(&p->refcnt, &unused_peers.lock)) {

Why not:
	if (atomic_dec_and_test(&p->refcnt)) {
		spin_lock_bh(&inet_peer_unused_lock);
		...
Jarek P.
