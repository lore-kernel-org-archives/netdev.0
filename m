From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH,RFT] 8139cp TSO support
Date: Sun, 29 Aug 2004 19:02:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41326079.9090402@pobox.com>
References: <20040829212205.GA2864@havoc.gtf.org> <20040829222831.GA9496@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040829222831.GA9496@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [...]
> 
>>Also, the r8169 implementation should be similar, if someone (Francois?)
>>wants to tackle it.
> 
> 
> I'll copy and test it tomorrow on r8169 if nobody beats me.
> 
> On a related note, 8139cp probably wants something like the patch below for
> the usual SG handling (on top of 2.6.9-rc1 + -mm1 + TSO patch):
> 
> - suspicious length in pci_unmap_single;
> - wait for the last frag before freeing the relevant skb;
> - no need to crash when facing some unexpected csum combination.

Looks OK except for


> diff -puN drivers/net/8139cp.c~8139cp-010 drivers/net/8139cp.c
> --- linux-2.6.9-rc1/drivers/net/8139cp.c~8139cp-010	2004-08-29 23:47:07.000000000 +0200
> +++ linux-2.6.9-rc1-fr/drivers/net/8139cp.c	2004-08-30 00:16:13.000000000 +0200
> @@ -807,7 +807,6 @@ static int cp_start_xmit (struct sk_buff
>  
>  		cp->tx_skb[entry].skb = skb;
>  		cp->tx_skb[entry].mapping = mapping;
> -		cp->tx_skb[entry].frag = 0;
>  		entry = NEXT_TX(entry);
>  	} else {
>  		struct cp_desc *txd;

You definitely want to set .len on the no-frags path...
