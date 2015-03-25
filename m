From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio: change comment in transmit
Date: Wed, 25 Mar 2015 00:34:55 -0400 (EDT)
Message-ID: <20150325.003455.923244010335019144.davem@davemloft.net>
References: <20150324162207.6d4ecf48@urahara> <87y4mlhglx.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	mst@redhat.com
To: rusty@rustcorp.com.au
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87y4mlhglx.fsf@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 25 Mar 2015 14:29:38 +1030

> I note that there's still no comment saying "don't do this" in
> netdevice.h; I gather returning NETDEV_TX_BUSY is still considered a Bad
> Thing?

You're not supposed to do it still, that's right.

If the driver returns NETDEV_TX_BUSY it means that it is not
maintaining the TX queues stop/start state properly.

It was kept around for drivers that we didn't want to convert
or fix up at the time (this is circa two decades ago).

I realize that there are situations for some devices where this is
difficult to achieve, but the stack really does a non-trivial amount
of useless work if you don't play along nicely.

If you grep drivers/net for it, the majority of the returns are in
assertion failure paths in the TX handler of those drivers.
NETDEV_TX_BUSY is not being returned in a normal path of operation.

> (Does it really BUG_ON?)

No, it doesn't.
