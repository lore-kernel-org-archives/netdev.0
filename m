From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] arcnet: com90xx: add __init attribute
Date: Tue, 19 Apr 2016 20:18:01 -0400 (EDT)
Message-ID: <20160419.201801.1678960326029844695.davem@davemloft.net>
References: <1460991338-9845-1-git-send-email-Julia.Lawall@lip6.fr>
	<1460991338-9845-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m.grzeschik@pengutronix.de, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mcgrof@kernel.org, josh@joshtriplett.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460991338-9845-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon, 18 Apr 2016 16:55:35 +0200

> Add __init attribute on a function that is only called from other __init
> functions and that is not inlined, at least with gcc version 4.8.4 on an
> x86 machine with allyesconfig.  Currently, the function is put in the
> .text.unlikely segment.  Declaring it as __init will cause it to be put in
> the .init.text and to disappear after initialization.
> 
> The result of objdump -x on the function before the change is as follows:
> 
> 0000000000000000 l     F .text.unlikely 00000000000000bf check_mirror
> 
> And after the change it is as follows:
> 
> 0000000000000000 l     F .init.text	00000000000000ba check_mirror
> 
> Done with the help of Coccinelle.  The semantic patch checks for local
> static non-init functions that are called from an __init function and are
> not called from any other function.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied to net-next, thanks.
