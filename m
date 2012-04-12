From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: smsc911x: fix RX FIFO fastforwarding when
 dropping packets
Date: Thu, 12 Apr 2012 16:01:39 +0200
Message-ID: <1334239299.5300.6478.camel@edumazet-glaptop>
References: <1334221644-16056-1-git-send-email-will.deacon@arm.com>
	 <1334222448.5300.6046.camel@edumazet-glaptop>
	 <20120412125355.GG16025@mudshark.cambridge.arm.com>
	 <1334235963.5300.6361.camel@edumazet-glaptop>
	 <20120412134757.GH16025@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36126 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933809Ab2DLOBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 10:01:47 -0400
Received: by bkcik5 with SMTP id ik5so1540360bkc.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 07:01:45 -0700 (PDT)
In-Reply-To: <20120412134757.GH16025@mudshark.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-12 at 14:47 +0100, Will Deacon wrote:

> 
> I don't think we want an skb_reserve at all, since the hardware shifts the
> data in the RX FIFO, meaning that we will read two bytes of 0 anyway before
> valid data.
> 
> > 		skb_put(skb, pktlength - 4);
> 
> I can move the put here if you like, but we need to use pktwords << 2 to
> make sure that we read the leading and trailing zeroes inserted by the
> hardware.

before calling linux stack, you'll have to skip those 2 bytes.

This is skb_reserve() purpose.
