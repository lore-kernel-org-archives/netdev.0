From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] ax25: avoid overflows in ax25_setsockopt()
Date: Wed, 28 Dec 2011 14:08:19 -0500 (EST)
Message-ID: <20111228.140819.861154490395622829.davem@davemloft.net>
References: <1325014999-28931-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	ralf@linux-mips.org
To: xi.wang@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1325014999-28931-1-git-send-email-xi.wang@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xi Wang <xi.wang@gmail.com>
Date: Tue, 27 Dec 2011 14:43:19 -0500

> Commit be639ac6 ("NET: AX.25: Check ioctl arguments to avoid overflows
> further down the road") rejects very large arguments, but doesn't
> completely fix overflows on 64-bit systems.  Consider the AX25_T2 case.
> 
> 	int opt;
> 	...
> 	if (opt < 1 || opt > ULONG_MAX / HZ) {
> 		res = -EINVAL;
> 		break;
> 	}
> 	ax25->t2 = opt * HZ;
> 
> The 32-bit multiplication opt * HZ would overflow before being assigned
> to 64-bit ax25->t2.  This patch changes "opt" to unsigned long.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>

Applied.
