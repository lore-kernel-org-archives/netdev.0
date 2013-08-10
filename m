From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sctp: fix panic during skb_orphan()
Date: Fri, 09 Aug 2013 18:20:22 -0700
Message-ID: <1376097622.20509.19.camel@edumazet-glaptop>
References: <20130809.133720.232424253997869104.davem@davemloft.net>
	  <1376085487-6466-1-git-send-email-vyasevich@gmail.com>
	 <1376090435.20509.13.camel@edumazet-glaptop> <52058BB2.4010606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-sctp@vger.kernel.org, dborkman@redhat.com
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:44272 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968331Ab3HJBU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 21:20:26 -0400
In-Reply-To: <52058BB2.4010606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-09 at 20:39 -0400, Vlad Yasevich wrote:
> On 08/09/2013 07:20 PM, Eric Dumazet wrote:

> > Why not using a dummy destructor ?
> 
> It would just be useless once we do proper accounting for all chunks.
> But, I'll send a different idea if this is just too ugly.

Setting skb->sk is no accounting.

It seems you would better use skb->cb[] so that you are 100% sure this
skb->sk doesn't leak outside of SCTP code.
