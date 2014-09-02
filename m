From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/5] net: mvberlin_eth: add an Ethernet driver for
 Marvell Berlin
Date: Mon, 01 Sep 2014 20:26:32 -0700 (PDT)
Message-ID: <20140901.202632.1784070145688270115.davem@davemloft.net>
References: <1409320263-10295-1-git-send-email-antoine.tenart@free-electrons.com>
	<1409320263-10295-2-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409320263-10295-2-git-send-email-antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Date: Fri, 29 Aug 2014 15:50:59 +0200

> +struct rx_desc {
> +	u16 buf_size;		/* Buffer size				*/
> +	u16 byte_cnt;		/* Descriptor buffer byte count		*/
 ...
> +	u16 byte_cnt;		/* buffer byte count			*/
> +	u16 l4i_chk;		/* CPU provided TCP checksum		*/

I'm really suspcious that you're ordering these two members differently
than that used by the mv643xx_eth driver.

Looking at a diff of the two drivers, most of the transmit and recieve paths
are largely the same.

WRT. register differences, adding indirection to handle that is a no-brainer
because the cost of the register access itself will absolutely dwarf whatever
it costs to do an indirect call or whatever to implement the register access.

I really think you should look into sharing code more seriously.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
