From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 02:15:33 -0700
Message-ID: <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	 <20141015.002514.384962932982389732.davem@davemloft.net>
	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-10-15 at 05:34 +0000, Jiafei.Pan@freescale.com wrote:
 
> Yes, for this matter, in order to do this we should modify the Ethernet
> drivers. For example, driver A want to driver B, C, D.. to support driver
> A's Hardware block access functions, so we have to modify driver B, C, D...
> It will be so complex for this matter.
> 
> But by using my patch, I just modify a Ethernet device (I don't care
> Which driver it is used) flag in driver A in order to implement this
> Ethernet device using hardware block access functions provided by
> Driver A.

We care a lot of all the bugs added by your patches. You have little
idea of how many of them were added. We do not want to spend days of
work explaining everything or fixing all the details for you.

Carefully read net/core/skbuff.c, net/core/dev.c, GRO layer, you'll see
how many spots you missed.

You cannot control how skbs are cooked before reaching your driver
ndo_start_xmit(). You are not going to add hooks in UDP , TCP, or other
drivers RX path. This would be absolutely insane.

Trying to control how skb are cooked in RX path is absolutely something
drivers do, using page frags that are read-only by all the stack.

Fix your driver to use existing infra, your suggestion is not going to
be accepted.


