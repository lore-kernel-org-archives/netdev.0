From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: skb_tx_hash() improvements
Date: Fri, 01 May 2009 10:52:01 +0200
Message-ID: <49FAB831.6020700@cosmosbay.com>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>	 <20090430.022417.07019547.davem@davemloft.net>	 <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>	 <20090430.070811.260649067.davem@davemloft.net> <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com> <49FA932B.4030405@cosmosbay.com> <49FAB2D5.60508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Dickinson <andrew@whydna.net>, jelaas@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37956 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbZEAIwK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 04:52:10 -0400
In-Reply-To: <49FAB2D5.60508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David, here is the followup I promised
>=20
> Thanks
>=20
> [PATCH] net: skb_tx_hash() improvements
>=20
> When skb_rx_queue_recorded() is true, we dont want to use jhash distr=
ibution
> as the device driver exactly told us which queue was selected at RX t=
ime.
> jhash makes a statistical shuffle, but this wont work with only 8 dif=
ferent inputs.
>=20
> We also need to implement a true reciprocal division, to not disturb
> symmetric setups (when number of tx queues matches number of rx queue=
s)
> and cpu affinities.
>=20
> This patch introduces a new helper, dev_real_num_tx_queues_set()
> to set both real_num_tx_queues and its reciprocal value,
> and makes all drivers use this helper.

Oh well, this was wrong, I took divide result while we want a modulo !

Need to think a litle bit more :)



