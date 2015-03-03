From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bcm63xx_enet: fix poll callback.
Date: Tue, 03 Mar 2015 06:18:02 -0800
Message-ID: <1425392282.5130.176.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425383112-23851-1-git-send-email-nschichan@freebox.fr>
	 <1425389399.5130.169.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425390142.5130.173.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F5BCE0.3060507@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	Felipe Balbi <balbi@ti.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F5BCE0.3060507@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 14:53 +0100, Nicolas Schichan wrote:
> On 03/03/2015 02:42 PM, Eric Dumazet wrote:
> >> To avoid that, I would take priv->tx_lock only once, or add a limit on
> >> the number of skbs that can be drained per round.
> > 
> > Something like this (untested) patch
> 
> I'm not against testing this patch, but we do not have any SMP capable bcm63xx
> board here so I don't think it will be of any use.
> 
> bcm6358 and bcm6368 do indeed have two MIPS threads, but SMP is not possible
> (due to a data cache or TLB shared across all MIPS threads , unbearably
> complicating things, IIRC).
> 
> bcm63xx ARM SoCs look like they can support SMP though.
> 
> Regards,
> 

I am reasonably confident the patch is OK, but I cannot easily compile
it on my laptop (x86_64) :

  CC      drivers/net/ethernet/broadcom/bcm63xx_enet.o
drivers/net/ethernet/broadcom/bcm63xx_enet.c:34:30: fatal error:
bcm63xx_dev_enet.h: No such file or directory
 #include <bcm63xx_dev_enet.h>
                              ^
compilation terminated.
make[1]: *** [drivers/net/ethernet/broadcom/bcm63xx_enet.o] Error 1
make: *** [drivers/net/ethernet/broadcom/bcm63xx_enet.o] Error 2
