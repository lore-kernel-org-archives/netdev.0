From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dst_release() cleanup
Date: Tue, 08 Dec 2009 20:35:03 -0800 (PST)
Message-ID: <20091208.203503.45117329.davem@davemloft.net>
References: <20091207091746.51d8958a@nehalam>
	<alpine.DEB.2.00.0912072056350.27565@melkinpaasi.cs.helsinki.fi>
	<4B1D53CA.3060004@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755472AbZLIEe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:34:56 -0500
In-Reply-To: <4B1D53CA.3060004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Dec 2009 20:13:14 +0100

> Ilpo Järvinen a écrit :
> 
>> That's their problem then to fix all relevant places. ...That won't even 
>> compile because of constructs like this:
>> 
>> 	if (WARN_ON(x))
>> 
>> ...To my knowing this perfectly legal way of doing this.
>> 
> 
> Sure, but let be conservative :)

It certainly jumped out at me.

Using side effects in a debugging macro, that's always asking for
trouble.  Every time I see this thing I'm going to do a double
take on it.

We can pull the return value into an 'int' with a descriptive name
such as "orig_dst_refcnt", and also use WARN() to make a descriptive
error message for kerneloops.org to log if it triggers.

Ok Eric?
