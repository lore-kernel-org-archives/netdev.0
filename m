From: Graham Gower <graham.gower@gmail.com>
Subject: Re: [PATCH] [TRIVIAL] prism54/islpci_eth.c: dev_kfree_skb in irq context
Date: Wed, 4 Jan 2006 09:33:27 +1030
Message-ID: <6ec4247d0601031503k2232c472o@mail.gmail.com>
References: <6.1.1.1.2.20060103105620.02c523e0@192.168.6.12>
	 <6ec4247d0601030419w377fd396x@mail.gmail.com>
	 <43BA7810.6010308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Roger While <simrw@sim-basis.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932511AbWACXD3@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <43BA7810.6010308@trash.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/01/06, Patrick McHardy <kaber@trash.net> wrote:
> Graham Gower wrote:
> > My logs were starting to fill with messages exatcly like that mentioned here:
> > http://patchwork.netfilter.org/netfilter-devel/patch.pl?id=2840
> >
> > In any event, the patch at the end of that link was never applied (it doesn't
> > fix the other call to dev_kfree_skb). After applying my patch, I've not had any
> > more messages in the logs.
>
> The patch has been applied to 2.6.15-rc. Only the first hunk of your
> patch is still required, but it doesn't apply anymore. Can you send
> a new patch against 2.6.15 please?
>

Ok, here's a new one. Hope I got it right this time.

Signed-off-by: Graham Gower <graham.gower@gmail.com>

--- linux-2.6.15/drivers/net/wireless/prism54/islpci_eth.c.orig
+++ linux-2.6.15/drivers/net/wireless/prism54/islpci_eth.c
@@ -177,7 +177,7 @@
 #endif

 			newskb->dev = skb->dev;
-			dev_kfree_skb(skb);
+			dev_kfree_skb_irq(skb);
 			skb = newskb;
 		}
 	}
