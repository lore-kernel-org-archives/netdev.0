From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Move some code into __init section when
 CONFIG_NET_NS=n (v2)
Date: Mon, 08 Oct 2007 20:38:57 -0700 (PDT)
Message-ID: <20071008.203857.92246440.davem@davemloft.net>
References: <470A2E81.5050006@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752937AbXJIDi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 23:38:58 -0400
In-Reply-To: <470A2E81.5050006@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 08 Oct 2007 17:20:01 +0400

> With the net namespaces many code leaved the __init section,
> thus making the kernel occupy more memory than it did before.
> Since we have a config option that prohibits the namespace
> creation, the functions that initialize/finalize some netns
> stuff are simply not needed and can be freed after the boot.
> 
> Currently, this is almost not noticeable, since few calls
> are no longer in __init, but when the namespaces will be
> merged it will be possible to free more code. I propose to 
> use the __net_init, __net_exit and __net_initdata "attributes"
> for functions/variables that are not used if the CONFIG_NET_NS
> is not set to save more space in memory.
> 
> The exiting functions cannot just reside in the __exit section,
> as noticed by David, since the init section will have 
> references on it and the compilation will fail due to modpost 
> checks. These references can exist, since the init namespace 
> never dies and the exit callbacks are never called. So I 
> introduce the __exit_refok attribute just like it is already 
> done with the __init_refok.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks for fixing this up Pavel.
