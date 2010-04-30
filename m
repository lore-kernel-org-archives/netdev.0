From: Karsten Keil <isdn@linux-pingi.de>
Subject: Re: possible off by one error in drivers/isdn/divert/divert_procfs.c
Date: Sat, 1 May 2010 00:12:14 +0200
Message-ID: <201005010012.14816.isdn@linux-pingi.de>
References: <BLU108-W15F33D55974CB43800BEB59C000@phx.gbl>
Reply-To: isdn@linux-pingi.de
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: d binderman <dcb314@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:51473 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759764Ab0D3WMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 18:12:21 -0400
In-Reply-To: <BLU108-W15F33D55974CB43800BEB59C000@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Freitag, 30. April 2010 23:15:17 d binderman wrote:
> Hello there,
> 
> I've just been looking at the Linux kernel linux-2.6.34-rc6.  I notice the
> source code in file drivers/isdn/divert/divert_procfs.c, around line 50 is
> 
>         if (!(ib = kmalloc(sizeof(struct divert_info) + strlen(cp),
>  GFP_ATOMIC))) return;        /* no memory */
>         strcpy(ib->info_start, cp);     /* set output string */
> 
> 
> Shouldn't that be
> 
>         if (!(ib = kmalloc(sizeof(struct divert_info) + strlen(cp) + 1,
>  GFP_ATOMIC))) return;        /* no memory */
>         strcpy(ib->info_start, cp);     /* set output string */
> 
> +1 for the zero byte ?
> 

No the struct divert_info already add 2 bytes as size of the info_start field.

So in real it has one byte more as needed.

Same think with the code in drivers/isdn/divert/divert_procfs.c

Karsten
