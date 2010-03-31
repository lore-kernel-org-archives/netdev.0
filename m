From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skb_put: remove not needed check for skb linearity
Date: Tue, 30 Mar 2010 23:55:55 -0700 (PDT)
Message-ID: <20100330.235555.235686050.davem@davemloft.net>
References: <20100330130131.8432.43671.stgit@pauliusz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paulius.zaleckas@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45759
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752026Ab0CaGzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:55:53 -0400
In-Reply-To: <20100330130131.8432.43671.stgit@pauliusz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Date: Tue, 30 Mar 2010 16:01:31 +0300

> It is safe to call skb_put() on packets containing fragments.
> 
> Actually I have a case where I allocate packet header with some
> extra headroom and then I dynamically add data as frag_list. After
> adding frags I have to add more data to header and skb_put()
> just BUG's on me :)
> 
> And we will save couple instructions for CPU.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>

No, you really cannot do this, that check is very much intentional and
needs to be there.  Otherwise we will allow violations of the
semantics of the SKB data area.

Once you put even one byte of non-linear data into the skb, all data
must be "put" to the end of that non-linear area, without exception.

You can't just stuff arbitrary things "in-between" the linear and the
non-linear stuff.

You'll need to find a way to construct your SKBs properly such that
the entirety of the linear area is constructed before you start
adding non-linear elements.
