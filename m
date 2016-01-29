From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net 2/2] net/mlx5e: Use a private copy of netdev ops
Date: Fri, 29 Jan 2016 15:17:54 +0200
Message-ID: <CAJ3xEMhZmSMVBUq7Ry++KGK_Ec2PG++MUps=yA5PoMrhayzYQQ@mail.gmail.com>
References: <1453906945-25414-1-git-send-email-ogerlitz@mellanox.com>
	<1453906945-25414-3-git-send-email-ogerlitz@mellanox.com>
	<20160128.200038.1283811216884732396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:33618 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbcA2NRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 08:17:55 -0500
Received: by mail-ig0-f194.google.com with SMTP id h5so4313690igh.0
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 05:17:55 -0800 (PST)
In-Reply-To: <20160128.200038.1283811216884732396.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 6:00 AM, David Miller <davem@davemloft.net> wrote:

> This is not the canonical way to fix this.  Please look at how
> other drivers handle this situation before inventing your own
> way of solving the problem.

Dave, I was aware that other drivers do that differently, but the
maintainer here preferred to go this way and I didn't see a deep
reason why not.

> The proper way is to have multiple netdevice ops instances, and simply
> choose the one which is correct for the chip in question.

yep, but - this can become little lengthy if you have N ndos shared
among (say) three different profiles with m1, m2, m3 distinct ndos -
so we thought it can be a bit more elegant to do selective assignment
within a function and not as three globals.

> You should also mark the ops as const.  They should never _ever_ be
> modified at runtime.

okay

Or.
