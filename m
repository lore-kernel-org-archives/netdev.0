From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: Blackfin Ethernet MAC driver compile error
Date: Thu, 04 Oct 2007 17:20:08 +0800
Message-ID: <1191489608.6139.10.camel@roc-laptop>
References: <a425f86c0710020430o3507eeb2veb104dc936f230dd@mail.gmail.com>
	 <200710021136.38514.rgetz@blackfin.uclinux.org>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kalle Pokki <kalle.pokki@iki.fi>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bryan.wu@analog.com
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:3360 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759746AbXJDJUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 05:20:15 -0400
In-Reply-To: <200710021136.38514.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-02 at 23:36 +0800, Robin Getz wrote:
> On Tue 2 Oct 2007 07:30, Kalle Pokki pondered: 
> > The Blackfin Ethernet MAC driver does not compile. It seems the
> driver is 
> > missing some pinmux defines. 
> > 
> >   CC      drivers/net/bfin_mac.o 
> > drivers/net/bfin_mac.c: In function 'setup_pin_mux': 
> > drivers/net/bfin_mac.c:275: error: 'P_MII0' undeclared (first use
> in 
> > this function) 
> > drivers/net/bfin_mac.c:275: error: (Each undeclared identifier is 
> > reported only once 
> > drivers/net/bfin_mac.c:275: error: for each function it appears in.)
> 
> Unfortunately, Bryan is out for the week, so he can't update things..

I am here, although it is National Day holiday in China and I am not in
office.
> 
> The updates to include/asm-blackfin/mach-bf537/portmux.h seem to have
> been 
> missing from Bryan's git tree, and therefore were not pushed to
> Linus's tree.
> 
Yes, it was not merged to Linus's tree almost one month ago.
But now Linus git-pull it from my git-tree 
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=66b1f1a982bf4dbad9fa0de25b8d95c4936f05c4

> Sigh. - Sorry about that.
> 
> When Bryan gets back, he will update things, but for now, this might
> work. (I 
> don't know if there are any other interdependencies).
> 
Sorry again, some important core API changes should be merged before
drivers.
> 
> --- portmux.h   2007-10-02 11:18:34.000000000 -0400 
> +++ ./linux-2.6.x/include/asm-blackfin/mach-bf537/portmux.h
> 2007-08-18 
> 19:37:22.000000000 -0400 
> @@ -99,11 +99,44 @@ 
>  #define P_SPORT0_DRPRI (P_DEFINED | P_IDENT(PORT_PJ8) | P_FUNCT(0)) 
>  #define P_SPORT0_TSCLK (P_DEFINED | P_IDENT(PORT_PJ9) | P_FUNCT(0)) 
>  #define P_SPORT0_TFS   (P_DEFINED | P_IDENT(PORT_PJ10) | P_FUNCT(0)) 
> -#define P_SPORT0_DTPRI (P_DEFINED | P_IDENT(PORT_PJ11) | P_FUNCT(1)) 
> +#define P_SPORT0_DTPRI (P_DEFINED | P_IDENT(PORT_PJ11) | P_FUNCT(0)) 
>  #define P_CAN0_RX      (P_DEFINED | P_IDENT(PORT_PJ4) | P_FUNCT(1)) 
>  #define P_CAN0_TX      (P_DEFINED | P_IDENT(PORT_PJ5) | P_FUNCT(1)) 
>  #define P_SPI0_SSEL3   (P_DEFINED | P_IDENT(PORT_PJ10) | P_FUNCT(1)) 
>  #define P_SPI0_SSEL2   (P_DEFINED | P_IDENT(PORT_PJ11) | P_FUNCT(1)) 
>  #define P_SPI0_SSEL7   (P_DEFINED | P_IDENT(PORT_PJ5) | P_FUNCT(2)) 
>   
> -#endif /* _MACH_PORTMUX_H_ */ 
> +#define P_MII0 {\ 
> +       P_MII0_ETxD0, \ 
> +       P_MII0_ETxD1, \ 
> +       P_MII0_ETxD2, \ 
> +       P_MII0_ETxD3, \ 
> +       P_MII0_ETxEN, \ 
> +       P_MII0_TxCLK, \ 
> +       P_MII0_PHYINT, \ 
> +       P_MII0_COL, \ 
> +       P_MII0_ERxD0, \ 
> +       P_MII0_ERxD1, \ 
> +       P_MII0_ERxD2, \ 
> +       P_MII0_ERxD3, \ 
> +       P_MII0_ERxDV, \ 
> +       P_MII0_ERxCLK, \ 
> +       P_MII0_ERxER, \ 
> +       P_MII0_CRS, \ 
> +       P_MDC, \ 
> +       P_MDIO, 0} 
> + 
> + 
> +#define P_RMII0 {\ 
> +       P_MII0_ETxD0, \ 
> +       P_MII0_ETxD1, \ 
> +       P_MII0_ETxEN, \ 
> +       P_MII0_ERxD0, \ 
> +       P_MII0_ERxD1, \ 
> +       P_MII0_ERxER, \ 
> +       P_RMII0_REF_CLK, \ 
> +       P_RMII0_MDINT, \ 
> +       P_RMII0_CRS_DV, \ 
> +       P_MDC, \ 
> +       P_MDIO, 0} 
> +#endif                                 /* _MACH_PORTMUX_H_ */
> 
> > drivers/net/bfin_mac.c:279: error: implicit declaration of function 
> > 'peripheral_request_list' 
> > drivers/net/bfin_mac.c:285: error: implicit declaration of function 
> > 'peripheral_free_list'
> 
> Arg.
> 
> This was in an arch/blackfin/kernel/bfin_gpio.c update that hasn't
> seem to 
> made it either.
> 
> In the future - we will make sure driver submissions are done in the
> correct 
> order - so the proper infrastructure is in the tree before the driver
> is 
> submitted. - Sorry.
> 
I will try my best to keep them in order or fix it as soon as possible,
-:)))

[!snip!]
> 
Thanks
-Bryan
> 
