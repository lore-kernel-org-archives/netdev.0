From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: defxx: skb_push() failing?
Date: Tue, 26 Mar 2013 08:15:00 -0700
Message-ID: <1364310900.1716.21.camel@edumazet-glaptop>
References: <5151B0CE.5000000@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, macro@linux-mips.org
To: David Oostdyk <daveo@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:48132 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934485Ab3CZPPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 11:15:04 -0400
Received: by mail-da0-f42.google.com with SMTP id n15so3715540dad.29
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 08:15:03 -0700 (PDT)
In-Reply-To: <5151B0CE.5000000@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-26 at 10:29 -0400, David Oostdyk wrote:
> Hello,
> 
> In dfx_xmt_queue_pkt() in defxx.c, there is a skb_push(3) call which 
> makes room for 3 packet request header bytes.  There is some discussion 
> in the driver explaining why those three bytes will be available.  I 
> have an old FDDI card that I'm trying to bring up:
> 
> 05:05.0 FDDI network controller: Digital Equipment Corporation 
> PCI-to-PDQ Interface Chip [PFI] (rev 02)
> 
> Most skbuffs that come through dfx_xmit_queue_pkt() have 11 bytes 
> between skb->head and skb->data.  On the other hand, at almost exactly 
> 60-second intervals, an skb arrives that has zero bytes between 
> skb->head and skb->data.  This normally causes a kernel panic, and for 
> the time I just skip over such skb's.
> 
> Does anyone have advice on where I should start digging to find the 
> cause of this?
> 

Have you read comments in defxx.c file around line 151 ?

If one skb arrives with not enough headroom, you could add a

WARN_ON_ONCE(skb_headroom(skb) < 3);

and report stack trace so that we can identify and fix the caller.
