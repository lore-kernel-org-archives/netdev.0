From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Wed, 06 Jun 2012 07:10:13 +0200
Message-ID: <1338959413.2760.3686.camel@edumazet-glaptop>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	 <88c43001441945e1431609db252b69e7@visp.net.lb>
	 <df211722d18136698aeeda2f17b876e2@visp.net.lb>
	 <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	 <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	 <79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	 <CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	 <20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49360 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935Ab2FFFKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 01:10:19 -0400
Received: by weyu7 with SMTP id u7so4053640wey.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 22:10:18 -0700 (PDT)
In-Reply-To: <20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-29 at 23:25 +0900, Hiroaki SHIMODA wrote:

> If I understand the code and spec correctly, TX interrupts are
> generated when TXDCTL.WTHRESH descriptors have been accumulated
> and write backed.
> 
> I tentatively changed the TXDCTL.WTHRESH to 1, then it seems
> that latency spikes are disappear.
> 
> drivers/net/ethernet/intel/e1000e/e1000.h
> @@ -181,7 +181,7 @@ struct e1000_info;
>  #define E1000_TXDCTL_DMA_BURST_ENABLE                          \
>         (E1000_TXDCTL_GRAN | /* set descriptor granularity */  \
>          E1000_TXDCTL_COUNT_DESC |                             \
> -        (5 << 16) | /* wthresh must be +1 more than desired */\
> +        (1 << 16) | /* wthresh must be +1 more than desired */\
>          (1 << 8)  | /* hthresh */                             \
>          0x1f)       /* pthresh */
> 


Was this patch officially submitted ?

Thanks !
