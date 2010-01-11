From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next-2.6] can: Unify droping of invalid tx skbs and
 netdev	stats
Date: Mon, 11 Jan 2010 20:13:50 +0100
Message-ID: <4B4B786E.80609@pengutronix.de>
References: <4B477BB7.2030108@hartkopp.net> <4B4B20E3.3070603@grandegger.com> <4B4B4765.30302@hartkopp.net> <4B4B77D3.6030200@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48973 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab0AKTNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 14:13:53 -0500
In-Reply-To: <4B4B77D3.6030200@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Marc Kleine-Budde wrote:
> Oliver Hartkopp wrote:
>> Wolfgang Grandegger wrote:
> 
>>>>  
>>>> +	if (skb->len != sizeof(*cf) || cf->can_dlc > 8) {
>>>> +		kfree_skb(skb);
>>>> +		dev->stats.tx_dropped++;
>>>> +		return NETDEV_TX_OK;
>>>> +	}
>>> A static inline function "invalid_can_skb(skb)" (or "no_can_skb") would
>>> be handy here:
>>>
>>> 	if (invalid_can_skb(skb)) {
>>> 		kfree_skb(skb);
>>> 		dev->stats.tx_dropped++;
>>> 		return NETDEV_TX_OK;		
>>> 	}
>> Another idea could be:
> 
>> 	if (can_dropped_invalid_skb(skb, dev))
>> 		return NETDEV_TX_OK;
> 
>> with
> 
>> static inline int can_dropped_invalid_skb(struct sk_buff *skb, struct net_device *dev)
>> {
>> 	const struct can_frame *cf = (struct can_frame *)skb->data;
> 
>> 	if (unlikely(skb->len != sizeof(*cf) || cf->can_dlc > 8)) {
>> 		kfree_skb(skb);
>> 		dev->stats.tx_dropped++;
>> 		return 1;
>> 	}
> 
>> 	return 0;
>> }
> 
> this functions looks nice, but I'd swap its arguments, in order to have
> the same signature as the alloc_can_skb() functions

I mean...have the struct net device the first argument

Marc
- --
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAktLeG4ACgkQjTAFq1RaXHPhswCfaeUWz6rQzthR02H+AtqF/kXw
UIcAn0LOdZy8UZP61O9vuQgFU21h6atO
=LQ1H
-----END PGP SIGNATURE-----
