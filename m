From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ipvlan: fix building without netfilter
Date: Thu, 22 Sep 2016 14:58:24 +0200
Message-ID: <2147423.Poz9bNzMml@wuerfel>
References: <20160922094130.2154824-1-arnd@arndb.de> <20160922.083205.2034005377472668654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: maheshb@google.com, dsa@cumulusnetworks.com, edumazet@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160922.083205.2034005377472668654.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, September 22, 2016 8:32:05 AM CEST David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Thu, 22 Sep 2016 11:40:52 +0200
> 
> > The new l3s mode in ipvlan relies on netfilter interfaces, but
> > the ipvlan driver can be configured when CONFIG_NETFILTER is disabled,
> > leading to a build error:
> > 
> > drivers/net/ipvlan/ipvlan.h:132:22: error: 'struct nf_hook_state' declared inside parameter list will not be visible outside of this definition or declaration [-Werror]
> > drivers/net/ipvlan/ipvlan_main.c:14:27: error: array type has incomplete element type 'struct nf_hook_ops'
> > ...
> > 
> > This adds a forward declaration for struct nf_hook_state, and hides
> > the newly added l3s code in an #ifdef.
> > 
> > Fixes: 4fbae7d83c98 ("ipvlan: Introduce l3s mode")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> I'm pretty sure I applied a Kconfig patch that added the
> necessary dependency.

Yes, I see the fix cf714ac147e0 ("ipvlan: Fix dependency issue") now, and
can confirm that today's linux-next works without my patch, thanks!

	Arnd
