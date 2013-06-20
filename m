From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: fec: Fix build for MCF5272
Date: Wed, 19 Jun 2013 17:00:18 -0700 (PDT)
Message-ID: <20130619.170018.1690166635385887009.davem@davemloft.net>
References: <1371575099-2962-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, festevam@gmail.com,
	linux-kernel@vger.kernel.org, Frank.Li@freescale.com,
	jim_baxter@mentor.com
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371575099-2962-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 18 Jun 2013 10:04:59 -0700

> Commits 4c09eed9 (net: fec: Enable imx6 enet checksum acceleration) and
> baa70a5c (net: fec: enable pause frame to improve rx prefomance for 1G
> network) introduced functionality into the FEC driver which is not
> supported on MCF5272. The registers used to implement this functionality
> do not exist on MCF5272. Since register defines for MCF5272 are separate
> from register defines for other chips, building images for MCF5272 fails
> as follows.
> 
> fec_main.c: In function 'fec_restart':
> fec_main.c:520:8: error: 'FEC_RACC' undeclared (first use in this function)
> fec_main.c:585:3: error: 'FEC_R_FIFO_RSEM' undeclared (first use in this function)
> fec_main.c:586:3: error: 'FEC_R_FIFO_RSFL' undeclared (first use in this function)
> fec_main.c:587:3: error: 'FEC_R_FIFO_RAEM' undeclared (first use in this function)
> fec_main.c:588:3: error: 'FEC_R_FIFO_RAFL' undeclared (first use in this function)
> fec_main.c:591:3: error: 'FEC_OPD' undeclared (first use in this function)
> 
> Adding the missing register defines is not an option, since the registers
> do not exist on MCF5272. Disable the added functionality for MCF5272 builds.
> 
> Cc: Frank Li <Frank.Li@freescale.com>
> Cc: Jim Baxter <jim_baxter@mentor.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.

> This problem exists in 3.9 as well, though only due to commit baa70a5c. The
> patch does therefore not cleanly apply to 3.9. Options I can see are to ignore
> the build error in 3.9, to back-port the patch manually, or to split it into
> two separate patches. David, let me know which approach you prefer. 

You can feel free to send me a backport for v3.9-stable, thanks.
