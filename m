From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/capi: avoid index overrun from command_2_index()
Date: Sun, 20 Jul 2014 22:25:45 -0700 (PDT)
Message-ID: <20140720.222545.289290525709647063.davem@davemloft.net>
References: <20140720134913.13895140074@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
	isdn@linux-pingi.de, isdn4linux@listserv.isdn4linux.de
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbaGUFZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 01:25:46 -0400
In-Reply-To: <20140720134913.13895140074@xenon.ts.pxnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun, 20 Jul 2014 15:49:12 +0200 (CEST)

> The result of the function command_2_index() is used to index two
> arrays mnames[] and cpars[] with max. index 0x4e but in its current
> form that function can produce results up to 3*(0x9+0x9)+0x7f = 0xb5.
> Legal values for the function's first argument (c) according to the
> CAPI 2.0 standard are 0x00..0x08, 0x41, 0x80, 0x82..0x88, and 0xff.
> This patch modifies command_2_index() in such a way that the result
> is unchanged for legal values of c, and guaranteed to be less or
> equal to 0x4e for any argument values.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Command value validation should occur at the callers, signalling
errors if invalid values are seen, and command_2_index() should
BUG_ON() such invalid values.
