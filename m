From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] sock_create bad error return
Date: Wed, 09 Aug 2006 20:47:45 -0700 (PDT)
Message-ID: <20060809.204745.102463311.davem@davemloft.net>
References: <20060809183138.332023530@localhost.localdomain>
	<20060809183348.999358659@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48033
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932287AbWHJDrj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 23:47:39 -0400
To: shemminger@osdl.org
In-Reply-To: <20060809183348.999358659@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 09 Aug 2006 11:31:39 -0700

> If socket create call races with module unload, it correctly
> fails the socket call but doesn't return an error. This race
> is theoritical because the sock->ops are always the same and
> non-modular.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I think the intention of the code is to return
-EAFNOSUPPORT which is set explicitly some lines
above, and this makes sense because if we can't grab
onto the module reference count it means the module
is in the process of being unloaded.
