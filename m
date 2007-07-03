From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Fix logic breakage due to DSACK separation
Date: Tue, 03 Jul 2007 14:25:54 -0700 (PDT)
Message-ID: <20070703.142554.133910878.davem@davemloft.net>
References: <Pine.LNX.4.64.0706160121180.12770@kivilampi-30.cs.helsinki.fi>
	<20070702.221454.18562227.davem@davemloft.net>
	<Pine.LNX.4.64.0707031122490.14307@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36559
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757965AbXGCVZe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 17:25:34 -0400
In-Reply-To: <Pine.LNX.4.64.0707031122490.14307@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 3 Jul 2007 13:52:35 +0300 (EEST)

> 1. fack_count in skb (your proposal months ago)
>    + Trivial arithmetics, no walking necessary to find it (ever)
>    - Very expensive in storage wise (like you have stated earlier)

We have a 4-byte hole in sk_buff currently on 64-bit
(right after the 'iif' member), however it's hard to
crib those 4-bytes into the ->cb[] area where we need
it since the cb needs to be 8-byte aligned.

I'm not against making some space if it makes things
exceedingly easier.
