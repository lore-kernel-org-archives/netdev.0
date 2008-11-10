From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [1/3] IRDA: Create new field tx_extra in skbuff
Date: Mon, 10 Nov 2008 19:35:46 +0300
Message-ID: <20081110163546.GA19804@ioremap.net>
References: <49185CBD.2040601@ceibo.fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org
To: Alex =?utf-8?B?VmlsbGFjw63CrXM=?= Lasso
	<avillaci@ceibo.fiec.espol.edu.ec>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:45094 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752963AbYKJQft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 11:35:49 -0500
Content-Disposition: inline
In-Reply-To: <49185CBD.2040601@ceibo.fiec.espol.edu.ec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex.

On Mon, Nov 10, 2008 at 11:09:33AM -0500, Alex Villac=C3=AD=C2=ADs Lass=
o (avillaci@ceibo.fiec.espol.edu.ec) wrote:
> The previous patchsets attempt to fix the clobbering of the irda=20
> information by storing it within the data payload itself, as an=20
> additional header. For this, space has been allocated via skb_pull (?=
!)=20
> and later, skb_reserve(). The problem with this approach is that  we =
do=20
> not have a guarantee that all skbuffs that are processed in the irda=20
> stack are actually allocated with functions that reserve the required=
=20
> space for the irda metadata, especially in the tx route. In addition,=
=20
> this approach mixes the payload data with metadata that should not be=
=20
> transmitted at all, which is a bit disorganized.

Do all irda transfers require that additional data?
You can simply change MAX_HEADER macro to be bigger than that size
if it has to be larger than existing the biggest ax25 layer, which I
doubt it has to.

This data is always allocated for all transmitted skbs. Reserve is also
properly done in sending functions.

> This is the first of 3 patches that try a different approach. Instead=
 of=20
> allocating an additional "header" within the data buffer itself, it=20
> introduces a new field within the skbuff, named tx_extra. This field=20
> should be used for passing data from the higher layers that is requir=
ed=20
> for the drivers to transmit the packet correctly, and formalizes the=20
> previous usage of the cb field by the irda stack. The only issue I se=
e=20
> is that every single skbuff carries an additional 32 bytes which are =
not=20

I really wanted to write a joke about existing practice of shrinking sk=
b
as much as possible sucking bits out of existing fields, but your
proposal to add 32 bytes just kicked me out of the chair, my head lande=
d
on the keyboard and result is quite miserable: kn cgjm ncfkjn chcmujhcm=
=2E

This 32 bytes will be unused by at least half of the packets (rx ones)
and on the machines, where irda is not used, it will be just a wasted
block. Moreover, head of the skb->data is also unused for irda in this
case...

What exactly should be carried in that area?

--=20
	Evgeniy Polyakov
