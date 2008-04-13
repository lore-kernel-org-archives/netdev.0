From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [PATCH 2/7] ATM cell alignment.
Date: Sun, 13 Apr 2008 12:24:41 +0100
Message-ID: <4801ED79.5090502@andyfurniss.entadsl.com>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk> <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:34119 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755742AbYDMLYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 07:24:45 -0400
In-Reply-To: <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:

> + The align to ATM cells is used for determining the (ATM) SAR
> + alignment overhead at the ATM layer. (SAR = Segmentation And
> + Reassembly).  This is for example needed when scheduling packet on an
> + ADSL connection.  Note that the extra ATM-AAL overhead is _not_
> + included in this calculation. This overhead is added in the kernel
> + before doing the rate table lookup, as this gives better precision
> + (as the table will always be aligned for 48 bytes).

I see overhead is unsigned short. For me using pppoa/vc mux my overhead 
is IP + 10. I am shaping on eth so skb->len is IP+14 hence I need a 
negative overhead.

Recently built a 2.6.25-rc7 and noticed the cell_align has been added 
and the tables jigged. I am (ab)using this at -5 now. Handy that I only 
need to patch TC rather than kernel and I guess I could use other TCs if 
I needed to shape other not atm ifs.

Russel Stuart's patches handled this case IIRC, has it been lost or have 
I missed something (as usual)?

Andy.
