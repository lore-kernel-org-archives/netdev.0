From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/5] gianfar: GRO_DROP is unlikely
Date: Tue, 12 Feb 2013 08:47:50 -0800
Message-ID: <1360687670.6884.9.camel@edumazet-glaptop>
References: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com>
	 <1360673237-349-2-git-send-email-claudiu.manoil@freescale.com>
	 <1360673237-349-3-git-send-email-claudiu.manoil@freescale.com>
	 <20130212163056.GA1000@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36047 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758698Ab3BLQrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 11:47:55 -0500
Received: by mail-ie0-f179.google.com with SMTP id k11so379461iea.24
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 08:47:55 -0800 (PST)
In-Reply-To: <20130212163056.GA1000@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 11:30 -0500, Paul Gortmaker wrote:
> [...]
>     50b8:       81 3c 01 f8     lwz     r9,504(r28)
>     50bc:       81 5c 01 fc     lwz     r10,508(r28)
>     50c0:       31 4a 00 01     addic   r10,r10,1
>     50c4:       7d 29 01 94     addze   r9,r9
>     50c8:       91 3c 01 f8     stw     r9,504(r28)
>     50cc:       91 5c 01 fc     stw     r10,508(r28)
>     50d0:       4b ff fc 58     b       4d28 <gfar_clean_rx_ring+0x118>

What I can see here is the counter is 64bit and arch is 32bit,
and no sync is used.

So ethtool -S has races.
