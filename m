From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO and IPoIB performance degradation
Date: Wed, 08 Mar 2006 12:53:45 -0800 (PST)
Message-ID: <20060308.125345.89171061.davem@davemloft.net>
References: <adaacc1raz9.fsf@cisco.com>
	<20060307.172336.107863253.davem@davemloft.net>
	<20060308125311.GE17618@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	shemminger@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932273AbWCHUxq@vger.kernel.org>
To: mst@mellanox.co.il
In-Reply-To: <20060308125311.GE17618@mellanox.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Date: Wed, 8 Mar 2006 14:53:11 +0200

> What I was trying to figure out was, how can we re-enable the trick without
> hurting TSO? Could a solution be to simply look at the frame size, and call
> tcp_send_delayed_ack if the frame size is small?

The problem is that this patch helps performance when the
receiver is CPU limited.

The old code would delay ACKs forever if the CPU of the
receiver was slow, because we'd wait for all received
packets to be copied into userspace before spitting out
the ACK.  This would allow the pipe to empty, since the
sender is waiting for ACKs in order to send more into
the pipe, and once the ACK did go out it would cause the
sender to emit an enormous burst of data.  Both of these
behaviors are highly frowned upon for a TCP stack.

I'll try to look at this some more later today.
