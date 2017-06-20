From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 09/10] net/mlx4_en: Replace TXBB_SIZE
 multiplications with shift operations
Date: Tue, 20 Jun 2017 08:45:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0026944@AcuExch.aculab.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
 <1497526540-30028-10-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "kernel-team@fb.com" <kernel-team@fb.com>,
        Eric Dumazet <edumazet@google.com>
To: 'Tariq Toukan' <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:58514 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdFTIpT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 04:45:19 -0400
In-Reply-To: <1497526540-30028-10-git-send-email-tariqt@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan
> Sent: 15 June 2017 12:36
> Define LOG_TXBB_SIZE, log of TXBB_SIZE, and use it with a shift
> operation instead of a multiplication with TXBB_SIZE.
> Operations are equivalent as TXBB_SIZE is a power of two.
> 
> Performance tests:
> Tested on ConnectX3Pro, Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
> 
> Gain is too small to be measurable, no degradation sensed.
> Results are similar for IPv4 and IPv6.

I can't imagine there is any difference at all.
The compiler will use a shift for a 'multiply by a constant power of 2'.

...
If you want to save a few cycles I think the loop:
> -		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE;
> +		for (i = 0; i < tx_info->nr_txbb << LOG_TXBB_SIZE;
requires the compiler generate code to read nr_txbb every
iteration.
Caching the values might help (unless it causes a different
register spill).

	David
