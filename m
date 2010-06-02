From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Wed, 02 Jun 2010 06:50:17 -0700 (PDT)
Message-ID: <20100602.065017.139108801.davem@davemloft.net>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
	<AANLkTilKJVZiKLRUlL7AeaqSnlAs2u5sTW7o2vfvEKns@mail.gmail.com>
	<20100602125527.GA20396@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@gmail.com, netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39865
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755062Ab0FBNuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:50:07 -0400
In-Reply-To: <20100602125527.GA20396@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 2 Jun 2010 14:55:27 +0200

> On Tue, Jun 01, 2010 at 05:39:22PM -0500, Andy Fleming wrote:
>> That's a bit hacky.  There is a dev_flags field, which could be used
>> for this.  Probably, we should add a more general way of saying what
>> sort of port this is.  But don't use the presence and absence of
>> "priv", as it could one day get used for a different purpose, and this
>> seems like it would leave us open to strange bugs.
> 
> Okay, I changed it.
> 
> At first, I was worried about using 'dev_flags' because I couldn't
> tell exactly who may write to this field. Looking at tg.c and
> broadcom.c, it appears that the MAC drivers may also write this
> field. In contrast, the 'priv' field is surely private.

No, I think using dev_flags is absolutely the wrong way to do about
this.

phy_device->priv "could one day get used for a different purpose"?
What in the world are you smoking Andy?

It's clearly a private state pointer for the PHY driver to use,
full stop.  There is absolutely no ambiguity of what this value
is and what it is used for and who owns it.  The comments in the
layout of struct phy_device state this clearly as well.

On the other hand, ->dev_flags is an entirely different matter.  It's
set based upon arguments passed into PHY driver interface attach calls
and used in other various ways by the generic PHY library code.

This is entirely different from ->priv which is not touched at all
by the generic PHY code, and thus ->priv is much safer to use for
private purposes like Richard's case here.

Richard, please respin your patch so that you're using the ->priv
field like in your original patch.

Thanks.
