From: Wei Liu <wei.liu2@citrix.com>
Subject: TSQ accounting skb->truesize degrades throughput for large packets
Date: Fri, 6 Sep 2013 11:16:35 +0100
Message-ID: <20130906101635.GI14104@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:20668 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab3IFKQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 06:16:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric

I have some questions regarding TSQ and I hope you can shed some light
on this.

Our observation is that with the default TSQ limit (128K), throughput
for Xen network driver for large packets degrades. That's because we now
only have 1 packet in queue.

I double-checked that skb->len is indeed <64K. Then I discovered that
TSQ actually accounts for skb->truesize and the packets generated had
skb->truesize > 64K which effectively prevented us from putting 2
packets in queue.

There seems to be no way to limit skb->truesize inside driver -- the skb
is already constructed when it comes to xen-netfront.

My questions are:
  1) I see the comment in tcp_output.c saying: "TSQ : sk_wmem_alloc
     accounts skb truesize, including skb overhead. But thats OK", I
     don't quite understand why it is OK.
  2) presumably other drivers will suffer from this as well, is it
     possible to account for skb->len instead of skb->truesize?
  3) if accounting skb->truesize is on purpose, does that mean we only
     need to tune that value instead of trying to fix our driver (if
     there is a way to)?

Thanks
Wei.
