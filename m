From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [EXPERIMENTAL PATCH] 2.4 tulip jumbo frames
Date: Tue, 09 Dec 2003 11:45:42 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD5FC36.5090405@pobox.com>
References: <20031209160632.D1345@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031209160632.D1345@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Two questions and a comment...

Would you split this into two patches?  The first simply adds, and uses, 
tp->rx_buf_sz.  The second adds PKT_BUF_SZ_MAX and mtu-related changes.

Have you looked at Donald Becker's changes to tulip.c?  He went through 
most of his drivers and made the changes necessary to support larger 
MTUs.  IIRC his tulip.c changes (which should be easily translate-able 
to 2.6.x tulip) were a bit more minimal than your patch, but still 
served the purpose.

For the comment:  I am curious why a VLAN_xxx constant is included in 
the calculation of max MTU, in the ->change_mtu hook?  IMO ->change_mtu 
simply needs to bind the MTU to the min and max h/w limits.  If 
VLAN_ETH_HLEN ever figures into the calculations, those calculations 
should occur elsewhere, not in ->change_mtu.

Thanks!

	Jeff
