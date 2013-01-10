From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tainted warnings with tcp splicing in 3.7.1
Date: Thu, 10 Jan 2013 07:29:47 -0800
Message-ID: <1357831787.27446.2168.camel@edumazet-glaptop>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan>
	 <1357750898.27446.33.camel@edumazet-glaptop>
	 <1357751372.27446.40.camel@edumazet-glaptop>
	 <1357801149.27446.1142.camel@edumazet-glaptop>
	 <20130110072136.GK9943@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christian Becker <c.becker@traviangames.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33150 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab3AJP3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 10:29:52 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so417421pad.26
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 07:29:51 -0800 (PST)
In-Reply-To: <20130110072136.GK9943@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-10 at 08:21 +0100, Willy Tarreau wrote:

> FWIW, I tested your patch here and did not notice any regression
> compared to last week-end tests, at various MTU size combinations.
> 

Thanks Willy

Tested-by: Willy Tarreau <w@1wt.eu>

I believe I need to fix net-next, 

commit 9ca1b22d6d228177e6f929f6818a1cd3d5e30c4a
(net: splice: avoid high order page splitting)

missed the loopback case : the skb->head might need several
linear_to_page() calls.

I'll send a patch after full testing.
