From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH linux-2.6.12-rc4-mm1] ethtool: Add NETIF_F_HW_CSUM
 support
Date: Mon, 23 May 2005 14:53:21 -0700
Message-ID: <20050523145321.49899042@dxpl.pdx.osdl.net>
References: <20050523210757.GB5910@us.ibm.com>
	<20050523.142009.74748115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jdmason@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050523.142009.74748115.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 May 2005 14:20:09 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> From: Jon Mason <jdmason@us.ibm.com>
> Subject: [PATCH linux-2.6.12-rc4-mm1] ethtool: Add NETIF_F_HW_CSUM support
> Date: Mon, 23 May 2005 16:07:57 -0500
> 
> > Added support to ethtool for NETIF_F_HW_CSUM.
> > 
> > Signed-off-by: Jon Mason <jdmason@us.ibm.com>
> 
> You cannot blindly set these flags, you need to provide
> a method for the driver to override the implementation of
> this method so it can return and error if it cannot provide
> support for this feature.

This patch makes perfect sense because it allows for common code to be
used by device drivers in their ethtool_ops. So this is the logical way to handle
this.

In other words,

drivers/net/sungem.c could do

static struct ethtool_ops gem_ethtool_ops = {

+	.get_tx_csum	  = ethtool_op_get_tx_csum,
+       .set_tx_csum       = ethtool_op_set_tx_hw_csum,
};
