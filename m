From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm_user: return error pointer instead of NULL
Date: Mon, 17 Sep 2012 09:16:42 +0200
Message-ID: <20120917071642.GC13023@secunet.com>
References: <1347572486-1628-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35666 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751462Ab2IQHQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 03:16:45 -0400
Content-Disposition: inline
In-Reply-To: <1347572486-1628-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 13, 2012 at 11:41:26PM +0200, Mathias Krause wrote:
> When dump_one_state() returns an error, e.g. because of a too small
> buffer to dump the whole xfrm state, xfrm_state_netlink() returns NULL
> instead of an error pointer. But its callers expect an error pointer
> and therefore continue to operate on a NULL skbuff.
> 
> This could lead to a privilege escalation (execution of user code in
> kernel context) if the attacker has CAP_NET_ADMIN and is able to map
> address 0.

Or it simply crashes with a NULL pointer dereference.

> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
