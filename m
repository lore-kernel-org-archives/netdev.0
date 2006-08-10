From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] net: socket family using RCU
Date: Wed, 09 Aug 2006 21:00:06 -0700 (PDT)
Message-ID: <20060809.210006.13768545.davem@davemloft.net>
References: <20060809183138.332023530@localhost.localdomain>
	<20060809183349.528294134@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47245
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932287AbWHJD77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 23:59:59 -0400
To: shemminger@osdl.org
In-Reply-To: <20060809183349.528294134@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 09 Aug 2006 11:31:42 -0700

> Replace the gross custom locking done in socket code for net_family[]
> with simple RCU usage. Some reordering necessary to avoid sleep
> issues with sock_alloc.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, but I had to do this by hand since it's not cleanly against
net-2.6.19:

>  	*res = sock;
>  	security_socket_post_create(sock, family, type, protocol, kern);

security_socket_post_create() returns an error code in the
current tree, and does a goto out_release; on error.

So I defer the *res = sock; until we know that this security
hook ran error-less.
