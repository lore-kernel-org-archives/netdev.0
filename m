From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next 2/2] gianfar: convert u64 status counters to
 atomic64_t
Date: Wed, 13 Feb 2013 17:22:44 +0200
Message-ID: <511BAFC4.9060006@freescale.com>
References: <1360715064-2689-1-git-send-email-paul.gortmaker@windriver.com> <1360715064-2689-3-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:27295
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934105Ab3BMPXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 10:23:44 -0500
In-Reply-To: <1360715064-2689-3-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/13/2013 2:24 AM, Paul Gortmaker wrote:
> While looking at some asm dump for an unrelated change, Eric
> noticed in the following stats count increment code:
>
>      50b8:       81 3c 01 f8     lwz     r9,504(r28)
>      50bc:       81 5c 01 fc     lwz     r10,508(r28)
>      50c0:       31 4a 00 01     addic   r10,r10,1
>      50c4:       7d 29 01 94     addze   r9,r9
>      50c8:       91 3c 01 f8     stw     r9,504(r28)
>      50cc:       91 5c 01 fc     stw     r10,508(r28)
>
> that a 64 bit counter was used on ppc-32 without sync
> and hence the "ethtool -S" output was racy.
>
> Here we convert all the values to use atomic64_t so that
> the output will always be consistent.
>

At least it seems that this conversion results in fewer asm
instructions, as apparently addze and the double lwz/stw are
not generated anymore. Hopefully it's faster too :P

Reviewed-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Thanks,
Claudiu
