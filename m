From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -next] netxen: fix build when CONFIG_INET=n
Date: Tue, 28 Jul 2009 11:32:54 -0700
Message-ID: <20090728113254.f0d1afb7.randy.dunlap@oracle.com>
References: <20090728174224.647cc3ba.sfr@canb.auug.org.au>
	<20090728112103.81f229d6.randy.dunlap@oracle.com>
	<7608421F3572AB4292BB2532AE89D5658187610C1C@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:56594 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390AbZG1SdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 14:33:24 -0400
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658187610C1C@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jul 2009 11:25:19 -0700 Dhananjay Phadke wrote:

> Thanks Randy for catching, I didn't run  CONFIG_INET=n build.
> 
> I think, better option is to wrap code in netxen_nic_main.c with CONFIG_INET check,
> since it's not a mandatory feature.

OK, I'll leave that to you then.


> -Dhananjay
> ________________________________________
> From: Randy Dunlap [randy.dunlap@oracle.com]
> Sent: Tuesday, July 28, 2009 11:21 AM
> To: Stephen Rothwell; davem@davemloft.net
> Cc: linux-next@vger.kernel.org; LKML; netdev; Dhananjay Phadke
> Subject: [PATCH -next] netxen: fix build when CONFIG_INET=n
> 
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix netxen build errors when CONFIG_INET=n:
> 
> netxen_nic_main.c:(.text+0x1abb8a): undefined reference to `in_dev_finish_destroy'
> netxen_nic_main.c:(.init.text+0xd86e): undefined reference to `register_inetaddr_notifier'
> netxen_nic_main.c:(.exit.text+0x1b70): undefined reference to `unregister_inetaddr_notifier'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: Dhananjay Phadke <dhananjay@netxen.com>
> ---
>  drivers/net/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-next-20090728.orig/drivers/net/Kconfig
> +++ linux-next-20090728/drivers/net/Kconfig
> @@ -2666,7 +2666,7 @@ config MYRI10GE_DCA
> 
>  config NETXEN_NIC
>         tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
> -       depends on PCI
> +       depends on PCI && INET
>         help
>           This enables the support for NetXen's Gigabit Ethernet card.
> 
> 
> 
> 
> ---
> ~Randy
> LPC 2009, Sept. 23-25, Portland, Oregon
> http://linuxplumbersconf.org/2009/


---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
