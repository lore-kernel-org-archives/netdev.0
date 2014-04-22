From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb_try_coalesce bug?
Date: Tue, 22 Apr 2014 13:05:16 -0700
Message-ID: <1398197116.29946.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140422120125.GC7019@eerihug-hybrid.rnd.ki.sw.ericsson.se>
	 <1398172293.29946.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5356C518.7050602@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:61617 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757071AbaDVUFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 16:05:18 -0400
Received: by mail-pd0-f172.google.com with SMTP id w10so876505pde.31
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 13:05:17 -0700 (PDT)
In-Reply-To: <5356C518.7050602@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-22 at 15:38 -0400, Jon Maloy wrote:

> 
> In the case I encountered, our head buffer is linear (skb->data_len == 0),
> so it is the real tailroom value that is returned. An alas, that one is big
> enough to contain the last (small) fragment of the message.


Whole point of skb_try_coalesce() is to coalesce as much as possible,
without guarantee of keeping some sort of 'segments'

skb_try_coalesce - try to merge skb to prior one

If you do not want this to happen, (you seem to want nothing else in
your head buffer skb->head), you need to add some logic.

A helper temporarily setting head->tail = head->end would do it I guess.
