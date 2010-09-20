From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Sun, 19 Sep 2010 17:17:25 -0700 (PDT)
Message-ID: <20100919.171725.245378386.davem@davemloft.net>
References: <1283852248.2338.160.camel@edumazet-laptop>
	<20100910.125449.235704956.davem@davemloft.net>
	<20100911123140.GA1939@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39646
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754336Ab0ITARH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 20:17:07 -0400
In-Reply-To: <20100911123140.GA1939@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 11 Sep 2010 14:31:40 +0200

> Otherwise seems OK, but I still would like to know the scenario
> demanding this change.

Ok Jarek, after some more consideration I agree with you.
Removing this kind of sharing would be unwise, ho hum...

While pondering over this I thought about why we even need
frag lists at all.  We need them for two reasons:

1) Because we have an inability to turn kmalloc data references into
   page based ones easily.

   We've run into this sort of problem with socket splice() too.

2) For recording the segmentation points of a fragmented packet.

We definitely don't use frag lists for performance, if you look
in the GRO history the GRO code specifically has been changed
to prefer accumulating into the page vector whenever possible
because using frag lists is a lot slower.

Anyways, even if we somehow solved #1 we'd still have a lot of
code (even bluetooth) using it for the sake of issue #2.

So for the time being there is no clear path for trying to
eliminate frag lists altogether if we wanted to do that either.

