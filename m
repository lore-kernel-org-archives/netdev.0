From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Fri, 13 Nov 2009 19:04:38 -0800 (PST)
Message-ID: <20091113.190438.78469912.davem@davemloft.net>
References: <4AF98A8C.9040201@novell.com>
	<20091114011229.GA18580@gondor.apana.org.au>
	<4AFE08EF.2030308@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ghaskins@novell.com, mst@redhat.com,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: gregory.haskins@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51257
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753602AbZKNDEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 22:04:22 -0500
In-Reply-To: <4AFE08EF.2030308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gregory Haskins <gregory.haskins@gmail.com>
Date: Fri, 13 Nov 2009 20:33:35 -0500

> Well, not with respect to the overall protocol, of course not.  But with
> respect to the buffer in question, it _has_ to be.  Or am I missing
> something?

sendfile() absolutely, and positively, is not.

Any entity can write to the pages being send via sendfile(), at will,
and those writes will show up in the packet stream if they occur
before the NIC DMA's the memory backed by those pages into it's
buffer.

There is zero data synchronization whatsoever, we don't lock the
pages, we don't block their usage while they are queued up in the
socket send queue, nothing like that.

The user returns long before it every hits the wire and there is zero
"notification" to the user that the pages in question for the
sendfile() request are no longer in use.

It seems that your understanding of how buffering and synchronization
works in the TCP stack has come out of a fairy tale :-)
