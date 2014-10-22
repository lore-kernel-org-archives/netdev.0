From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix saving TX flow hash in sock for outgoing
 connections
Date: Wed, 22 Oct 2014 10:39:02 -0700
Message-ID: <1413999542.9031.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413994321-20435-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36310 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027AbaJVRjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 13:39:04 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so4146109pab.30
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 10:39:04 -0700 (PDT)
In-Reply-To: <1413994321-20435-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 21:42 +0530, Sathya Perla wrote:
> The commit "net: Save TX flow hash in sock and set in skbuf on xmit"
> introduced the inet_set_txhash() and ip6_set_txhash() routines to calculate
> and record flow hash(sk_txhash) in the socket structure. sk_txhash is used
> to set skb->hash which is used to spread flows across multiple TXQs.
> 
> But, the above routines are invoked before the source port of the connection
> is created. Because of this all outgoing connections that just differ in the
> source port get hashed into the same TXQ.

Acked-by: Eric Dumazet <edumazet@google.com>

Are you really using the socket/flow hash to select a TXQ ?

Even with this patch, you have a good probability of multiple
cpus hitting same TXQ.
