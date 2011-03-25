From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myri10ge: small rx_done refactoring
Date: Fri, 25 Mar 2011 09:03:53 -0400
Message-ID: <4D8C92B9.1010109@myri.com>
References: <20110325112123.GA6218@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Brice Goglin <brice@myri.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Howells <dhowells@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:65309 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab1CYND6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 09:03:58 -0400
Received: by vws1 with SMTP id 1so751485vws.19
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2011 06:03:57 -0700 (PDT)
In-Reply-To: <20110325112123.GA6218@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/11 07:21, Stanislaw Gruszka wrote:
> Avoid theoretical race condition regarding accessing dev->features
> NETIF_F_LRO flag, which is illustrated below.
>
> CPU1					CPU2
>
> myri10ge_clean_rx_done():		myri10ge_set_flags():
> 					or
> 					myri10ge_set_rx_csum():
>
> if (dev->features&  NETIF_F_LRO)
>          setup lro
> 					dev->features |= NETIF_F_LRO
> 					or
> 					dev->features&= ~NETIF_F_LRO;
> if (dev->features&  NETIF_F_LRO)
>          flush lro
>
> On the way reduce myri10ge_rx_done() number of arguments and calls by
> moving mgp->small_bytes check into that function. That reduce code size
>
> from:
>     text	   data	    bss	    dec	    hex	filename
>    36644	    248	    100	  36992	   9080	drivers/net/myri10ge/myri10ge.o
>
> to:
>     text	   data	    bss	    dec	    hex	filename
>    36037	    247	    100	  36384	   8e20	drivers/net/myri10ge/myri10ge.o
>
> on my i686 system, what should also make myri10ge_clean_rx_done()
> being faster.
>
> Signed-off-by: Stanislaw Gruszka<sgruszka@redhat.com>

Thank you very much!

Acked by: Andrew Gallatin <gallatin@myri.com>


