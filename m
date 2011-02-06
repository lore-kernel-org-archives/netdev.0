From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] m68k/atari: ARAnyM - Add support for network access
Date: Sun, 06 Feb 2011 11:17:05 -0800 (PST)
Message-ID: <20110206.111705.183051866.davem@davemloft.net>
References: <1296989469-7844-1-git-send-email-geert@linux-m68k.org>
	<1296989469-7844-5-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	cz-bobek-lists-aranym@lists.bobek.cz,
	schmitz@opal.biophys.uni-duesseldorf.de, pstehlik@sophics.cz,
	M.Jurik@sh.cvut.cz, netdev@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1296989469-7844-5-git-send-email-geert@linux-m68k.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sun,  6 Feb 2011 11:51:09 +0100

> +	dev->trans_start = jiffies;

Device drivers no longer make this operation, the generic code
does it (see net/core/dev.c:dev_hard_start_xmit() and how it
invokes txq_trans_update() on ->ndo_start_xmit() success).

Therefore, please remove this line.

> +	pr_debug(DRV_NAME ": send %d bytes\n", len);

For consistency with other network drivers, add an appropriate CPP
define for "pr_fmt" and use netdev_info(), netdev_debug(), etc.

In situations where a netdev pointer is not available
(ie. pre-register_netdev()), use "dev_*()" instead.

Thanks.
