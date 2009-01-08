From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] net: fix section mismatch warnings in
	dccp/ccids/lib/tfrc.c
Date: Thu, 8 Jan 2009 21:28:47 -0200
Message-ID: <20090108232847.GV23891@ghostprotocols.net>
References: <200901081957.03413.lpotenza@inwind.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	DCCP Mailing List <dccp@vger.kernel.org>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>
To: Leonardo Potenza <lpotenza@inwind.it>,
	David Miller <davem@davemloft.net>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54496 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752525AbZAHX3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 18:29:07 -0500
Content-Disposition: inline
In-Reply-To: <200901081957.03413.lpotenza@inwind.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding netdev to the CC list.

Em Thu, Jan 08, 2009 at 07:57:03PM +0100, Leonardo Potenza escreveu:
> From: Leonardo Potenza <lpotenza@inwind.it>
> 
> Removed the __exit annotation of tfrc_lib_exit(), in order to suppress the following section mismatch messages:
> 
> WARNING: net/dccp/dccp.o(.text+0xd9): Section mismatch in reference from the function ccid_cleanup_builtins() to the function .exit.text:tfrc_lib_exit()
> The function ccid_cleanup_builtins() references a function in an exit section.
> Often the function tfrc_lib_exit() has valid usage outside the exit section
> and the fix is to remove the __exit annotation of tfrc_lib_exit.
> 
> WARNING: net/dccp/dccp.o(.init.text+0x48): Section mismatch in reference from the function ccid_initialize_builtins() to the function .exit.text:tfrc_lib_exit()
> The function __init ccid_initialize_builtins() references
> a function __exit tfrc_lib_exit().
> This is often seen when error handling in the init function
> uses functionality in the exit path.
> The fix is often to remove the __exit annotation of
> tfrc_lib_exit() so it may be used outside an exit section.
> 
> Signed-off-by: Leonardo Potenza <lpotenza@inwind.it>
> ---
> Index: linux-2.6/net/dccp/ccids/lib/tfrc.c
> ===================================================================
> --- linux-2.6.orig/net/dccp/ccids/lib/tfrc.c	2009-01-08 19:19:50.000000000 +0100
> +++ linux-2.6/net/dccp/ccids/lib/tfrc.c	2009-01-08 19:20:07.000000000 +0100
> @@ -36,7 +36,7 @@ out:
>  	return rc;
>  }
>  
> -void __exit tfrc_lib_exit(void)
> +void tfrc_lib_exit(void)
>  {
>  	tfrc_rx_packet_history_exit();
>  	tfrc_tx_packet_history_exit();

Thanks Leonardo,

Dave/Gerrit,

	Please apply.

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Thanks,

- Arnaldo
