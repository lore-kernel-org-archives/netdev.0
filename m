From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 2/4] bas_gigaset: collapse CR/LF at end of AT response
Date: Tue, 23 Feb 2010 14:19:19 +0100
Message-ID: <4B83D5D7.3040407@imap.cc>
References: <20100221-patch-gigaset-00.tilman@imap.cc> <20100221-patch-gigaset-02.tilman@imap.cc> <20100223063425.GA28744@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:48543 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752415Ab0BWNTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 08:19:23 -0500
In-Reply-To: <20100223063425.GA28744@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman schrieb:
> I am confused about what the value of MAX_RESP_SIZE means.
> Is it a hw restriction?

It's an arbitrary limitation in the driver. The hardware specification
says nothing about the possible length of AT responses from the device,
so we had to draw a line somewhere. 512 bytes have so far proved to be
amply sufficient.

In practice, the limit is only hit with the M10x devices (which transmit
commands and data over the same channel) when the state machine gets out
of sync and tries to interpret received payload data as AT responses.

> It seems that up to MAX_RESP_SIZE of string-data is permitted if the line
> is terminated by CR. But only MAX_RESP_SIZE -1  bytes if the line is
> terminated by LF or CR LF.

Note that when storing the CR in cs->respdata[0] for possible collapsing
with a subsequent LF, the cbytes counter is left at 0, so the CR gets
overwritten by the first character of the next response if there's no
intervening LF.

Thanks for reviewing,
Tilman
