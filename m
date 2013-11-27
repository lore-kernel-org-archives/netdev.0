From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] net: clamp ->msg_namelen instead of returning an error
Date: Wed, 27 Nov 2013 13:27:46 -0800
Message-ID: <1385587666.5352.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131127124021.GA2025@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Wong <normalperson@yhbt.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:33661 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622Ab3K0V1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 16:27:49 -0500
Received: by mail-yh0-f53.google.com with SMTP id b20so5436690yha.40
        for <netdev@vger.kernel.org>; Wed, 27 Nov 2013 13:27:48 -0800 (PST)
In-Reply-To: <20131127124021.GA2025@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-27 at 15:40 +0300, Dan Carpenter wrote:
> If kmsg->msg_namelen > sizeof(struct sockaddr_storage) then in the
> original code that would lead to memory corruption in the kernel if you
> had audit configured.  If you didn't have audit configured it was
> harmless.
> 
> There are some programs such as beta versions of Ruby which use too
> large of a buffer and returning an error code breaks them.  We should
> clamp the ->msg_namelen value instead.
> 
> Reported-by: Eric Wong <normalperson@yhbt.net>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Fixes: 1661bf364ae9 ("net: heap overflow in __audit_sockaddr()")

Acked-by: Eric Dumazet <edumazet@google.com>
