From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] farsync: fix invalid memory accesses in fst_add_one()
 and fst_init_card()
Date: Tue, 08 Jul 2014 15:20:57 -0700 (PDT)
Message-ID: <20140708.152057.490185410038470309.davem@davemloft.net>
References: <1404516950-17900-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kevin.curtis@farsite.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404516950-17900-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat,  5 Jul 2014 03:35:50 +0400

> -                }
> +			card->nports = i;
> +			return (card->nports == 0) ? err : 0;
> +		}

I don't think this is the right thing to do.

This will cause the caller to not free the IRQ or any of the
other resources.
