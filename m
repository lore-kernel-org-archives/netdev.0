From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: Fix RCU splat in af_key
Date: Mon, 24 Aug 2015 14:28:06 -0700
Message-ID: <1440451686.8932.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440451037-18564-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35786 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbbHXV2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 17:28:08 -0400
Received: by pdob1 with SMTP id b1so57753389pdo.2
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 14:28:08 -0700 (PDT)
In-Reply-To: <1440451037-18564-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-08-24 at 15:17 -0600, David Ahern wrote:
> Hit the following splat testing VRF change for ipsec:

> 
> In pfkey_sendmsg the net mutex is taken and then pfkey_broadcast takes
> the RCU lock.
> 
> Since pfkey_broadcast takes the RCU lock the allocation argument is
> pointless since GFP_ATOMIC must be used between the rcu_read_{,un}lock.
> The one call outside of rcu can be done with GFP_KERNEL.
> 
> Fixes: 7f6b9dbd5afbd ("af_key: locking change")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - removed allocation arg and hardcoded to GFP_ATOMIC during rcu locking

Acked-by: Eric Dumazet <edumazet@google.com>
