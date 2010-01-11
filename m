From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: Unify droping of invalid tx skbs and
	netdev	stats
Date: Mon, 11 Jan 2010 20:11:15 +0100
Message-ID: <4B4B77D3.6030200@pengutronix.de>
References: <4B477BB7.2030108@hartkopp.net> <4B4B20E3.3070603@grandegger.com>
	<4B4B4765.30302@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4B4B4765.30302-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Oliver Hartkopp wrote:
> Wolfgang Grandegger wrote:
> 
>>>  
>>> +	if (skb->len != sizeof(*cf) || cf->can_dlc > 8) {
>>> +		kfree_skb(skb);
>>> +		dev->stats.tx_dropped++;
>>> +		return NETDEV_TX_OK;
>>> +	}
>> A static inline function "invalid_can_skb(skb)" (or "no_can_skb") would
>> be handy here:
>>
>> 	if (invalid_can_skb(skb)) {
>> 		kfree_skb(skb);
>> 		dev->stats.tx_dropped++;
>> 		return NETDEV_TX_OK;		
>> 	}
> 
> Another idea could be:
> 
> 	if (can_dropped_invalid_skb(skb, dev))
> 		return NETDEV_TX_OK;
> 
> with
> 
> static inline int can_dropped_invalid_skb(struct sk_buff *skb, struct net_device *dev)
> {
> 	const struct can_frame *cf = (struct can_frame *)skb->data;
> 
> 	if (unlikely(skb->len != sizeof(*cf) || cf->can_dlc > 8)) {
> 		kfree_skb(skb);
> 		dev->stats.tx_dropped++;
> 		return 1;
> 	}
> 
> 	return 0;
> }

this functions looks nice, but I'd swap its arguments, in order to have
the same signature as the alloc_can_skb() functions

cheers, Marc

- --
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAktLd9MACgkQjTAFq1RaXHPaXACfRm0YdKxSPWX8lYudtvnq7WIo
8EMAn1nwRpxJ4mMgD/D4RNwZDT1oO9DY
=t+n5
-----END PGP SIGNATURE-----
