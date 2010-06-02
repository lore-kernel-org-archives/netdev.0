From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Wed, 2 Jun 2010 14:32:11 -0500
Message-ID: <AANLkTinR9_VoWX8zZu93MeohHvCbCy_P5XWHH3rxlPuH@mail.gmail.com>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
	<AANLkTilKJVZiKLRUlL7AeaqSnlAs2u5sTW7o2vfvEKns@mail.gmail.com>
	<20100602125527.GA20396@riccoc20.at.omicron.at>
	<20100602.065017.139108801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60642 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932493Ab0FBTcN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 15:32:13 -0400
Received: by wyi11 with SMTP id 11so2164989wyi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 12:32:12 -0700 (PDT)
In-Reply-To: <20100602.065017.139108801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 2, 2010 at 8:50 AM, David Miller <davem@davemloft.net> wrot=
e:
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Wed, 2 Jun 2010 14:55:27 +0200
>
>> On Tue, Jun 01, 2010 at 05:39:22PM -0500, Andy Fleming wrote:
>>> That's a bit hacky. =A0There is a dev_flags field, which could be u=
sed
>>> for this. =A0Probably, we should add a more general way of saying w=
hat
>>> sort of port this is. =A0But don't use the presence and absence of
>>> "priv", as it could one day get used for a different purpose, and t=
his
>>> seems like it would leave us open to strange bugs.
>>
>> Okay, I changed it.
>>
>> At first, I was worried about using 'dev_flags' because I couldn't
>> tell exactly who may write to this field. Looking at tg.c and
>> broadcom.c, it appears that the MAC drivers may also write this
>> field. In contrast, the 'priv' field is surely private.
>
> No, I think using dev_flags is absolutely the wrong way to do about
> this.

Yeah, I was clearly not thinking clearly.  dev_flags will be
overwritten, and is not meant for this.  I believe, what we should do
is add a "port" field to the PHY device, and if PCR_FIBER_SELECT is
set, then set the port field to PORT_FIBRE.  I'm not entirely clear on
the semantics of that field in the ethtool cmd, but it seems like the
right idea.


>
> phy_device->priv "could one day get used for a different purpose"?
> What in the world are you smoking Andy?
>
> It's clearly a private state pointer for the PHY driver to use,
> full stop. =A0There is absolutely no ambiguity of what this value
> is and what it is used for and who owns it. =A0The comments in the
> layout of struct phy_device state this clearly as well.

Yes, it's private, and I would be fine with using priv, I just didn't
think that it was correct to assign priv to point at the probe
function as a mechanism for indicating that fiber is being used.  I
believe that code should be more explicit than that.  priv is meant to
point at private data, not to indicate an arbitrary attribute of the
link by virtue of being non-null.

Andy
