From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] Revert "ipv4: use skb coalescing in
 defragmentation"
Date: Sat, 11 Jul 2015 07:01:57 +0200
Message-ID: <1436590917.24939.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1436571456-27905-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34075 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbbGKGJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 02:09:27 -0400
Received: by wifm2 with SMTP id m2so62132677wif.1
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 23:09:26 -0700 (PDT)
In-Reply-To: <1436571456-27905-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-07-11 at 01:37 +0200, Florian Westphal wrote:
> This reverts commit 3cc4949269e01f39443d0fcfffb5bc6b47878d45.
> 
> There is nothing wrong with coalescing during defragmentation, it
> reduces truesize overhead and simplifies things for the receiving
> socket (no fraglist walk needed).
> 
> However, it also destroys geometry of the original fragments.
> While that doesn't cause any breakage (we make sure to not exceed largest
> original size) ip_do_fragment contains a 'fastpath' that takes advantage
> of a present frag list and results in fragments that (in most cases)
> match what was received.
> 
> In case its needed the coalescing could be done later, when we're sure
> the skb is not forwarded.  But discussion during NFWS resulted in
> 'lets just remove this for now'.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
