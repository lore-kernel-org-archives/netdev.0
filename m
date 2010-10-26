From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reset gso header when the copied skb is linearized
Date: Tue, 26 Oct 2010 12:28:01 -0700 (PDT)
Message-ID: <20101026.122801.52191238.davem@davemloft.net>
References: <1288045398-3110-1-git-send-email-fleitner@redhat.com>
	<20101026.113157.233700961.davem@davemloft.net>
	<20101026192511.GA3494@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58822
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751786Ab0JZT1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:27:37 -0400
In-Reply-To: <20101026192511.GA3494@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Tue, 26 Oct 2010 17:25:11 -0200

> If I understand that correctly, the gso_segs is the number
> of GSO segments which are divided in non-linear way. When the
> copy is made using that function, the skb turns into a big
> one segment inlined. So, the idea of segments is lost and
> I'm not seeing how it is going to be divided again. 
> Later the NIC drives does, for example:

GSO has nothing to do with linearity, although it just so happens
to be that GSO packets tend to be non-linear due to the way
TCP builds such frames.

The GSO segment count is the number of MSS sized frames are
contained inside of a larger than MSS sized SKB.

That is it.  So the definition and meaning is independent of
linearity.

Thus, if we linearize a larger than MSS sized frame, it should still
have the same GSO attributes.
