From: petkan@nucleusys.com
Subject: Re: Pegasus: Bug / Correction (?)
Date: Fri, 14 Aug 2009 20:24:33 +0300 (EEST)
Message-ID: <e315af7ef85836e3c6dcdf6e1a6f5583.squirrel@nucleusys.com>
References: <8447d6730908130311vd6984e8t1dd5c1e32efbeb2c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	petkan@users.sourceforge.net
To: "Davide Rizzo" <elpa.rizzo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([78.83.248.164]:51728 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756088AbZHNRYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 13:24:31 -0400
In-Reply-To: <8447d6730908130311vd6984e8t1dd5c1e32efbeb2c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not good - the correction will disable set_address for older controllers. 
Have you tried this code on a different device?


                      Petko



> Bug Correction
> ADM8515 fails to read central 2 bytes of MAC address
> This patch solves the problem, but I didn't understand it.
>
> Signed-off-by: Davide Rizzo <elpa.rizzo@gmail.com>
> ---
> diff -urNp linux-2.6.30.4/drivers/net/usb/pegasus.c
> linux-2.6.30.4.elpa/drivers/net/usb/pegasus.c
> --- linux-2.6.30.4/drivers/net/usb/pegasus.c	2009-08-13 07:14:57.000000000
> +0200
> +++ linux-2.6.30.4.elpa/drivers/net/usb/pegasus.c	2009-08-13
> 08:39:01.000000000 +0200
> @@ -425,7 +425,6 @@ fail:
>  static inline void enable_eprom_write(pegasus_t * pegasus)
>  {
>  	__u8 tmp;
> -	int ret;
>
>  	get_registers(pegasus, EthCtrl2, 1, &tmp);
>  	set_register(pegasus, EthCtrl2, tmp | EPROM_WR_ENABLE);
> @@ -434,7 +433,6 @@ static inline void enable_eprom_write(pe
>  static inline void disable_eprom_write(pegasus_t * pegasus)
>  {
>  	__u8 tmp;
> -	int ret;
>
>  	get_registers(pegasus, EthCtrl2, 1, &tmp);
>  	set_register(pegasus, EpromCtrl, 0);
> @@ -486,9 +525,9 @@ static void set_ethernet_addr(pegasus_t
>  {
>  	__u8 node_id[6];
>
> -	if (pegasus->features & PEGASUS_II) {
> +/*if (pegasus->features & PEGASUS_II) {
>  		get_registers(pegasus, 0x10, sizeof(node_id), node_id);
> -	} else {
> +	} else*/ {
>  		get_node_id(pegasus, node_id);
>  		set_registers(pegasus, EthID, sizeof (node_id), node_id);
>  	}
>


