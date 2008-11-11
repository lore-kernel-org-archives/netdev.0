From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [irda-users] [1/3] IRDA: Create new field tx_extra in skbuff
Date: Tue, 11 Nov 2008 09:22:14 +0300
Message-ID: <20081111062214.GA20261@ioremap.net>
References: <49185CBD.2040601@ceibo.fiec.espol.edu.ec> <20081110163546.GA19804@ioremap.net> <20081110165544.GB19804@ioremap.net> <20081111010001.GB7511@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex =?utf-8?B?VmlsbGFjw63CrXM=?= Lasso
	<avillaci@ceibo.fiec.espol.edu.ec>,
	irda-users@lists.sourceforge.net, netdev@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:47409 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752075AbYKKGWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 01:22:17 -0500
Content-Disposition: inline
In-Reply-To: <20081111010001.GB7511@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Samuel.

On Tue, Nov 11, 2008 at 02:00:01AM +0100, Samuel Ortiz (samuel@sortiz.org) wrote:
> I thought about that solution, but the irda_skb_cb line field has to be kept
> per skb. It is needed for ircomm LMP flow control, in the skb destructor. I
> see that BT rfcomm does something similar, but uses the skbuff->sk as a
> rfcomm_dev pointer. As far as I understand the skbuff structure, that doesnt
> look like a reasonnable solution, as we cant assume the sk pointer won't be
> altered down the line.

It depends... If you own skb (when reference counter is 1), you can
owerwrite socket pointer with own data as long as destructor will also
be updated. You can try to clone skb and free old one to achieve this,
but it is not the fastest operation, althouhg I think both bt and irda
can afford that. Obviously in the first case you have to call old
destructor with old socket pointer also.

-- 
	Evgeniy Polyakov
