From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 02/11] ixgbe: Mask off check of frag_off as we only
 want fragment offset
Date: Fri, 12 Apr 2013 13:29:44 -0700
Message-ID: <1365798584.4459.70.camel@edumazet-glaptop>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	    <1365765866-15741-3-git-send-email-jeffrey.t.kirsher@intel.com>
	    <1365773328.4459.19.camel@edumazet-glaptop>
	   <1365774332.4459.24.camel@edumazet-glaptop> <51683884.2010509@intel.com>
	  <1365785511.4459.46.camel@edumazet-glaptop> <516850E4.8020504@intel.com>
	 <1365792277.4459.67.camel@edumazet-glaptop> <51686AAF.4090105@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:59652 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755506Ab3DLU3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 16:29:47 -0400
Received: by mail-da0-f43.google.com with SMTP id u36so1294798dak.16
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 13:29:47 -0700 (PDT)
In-Reply-To: <51686AAF.4090105@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 13:12 -0700, Alexander Duyck wrote:

> I think part of the trouble is we are debating reworking the wrong
> function.  We would probably be better off if we could come up with a
> generic way to handle the ixgbe_pull_tail function.  I think the only
> complaint I would have in using the __skb_get_poff in there is the fact
> that it would be copying the header in multiple chunks.  If it worked
> more like GRO where it just used an offset in the first frag instead of
> having to copy the headers separately to read them then I would be 100%
> on board.

__skb_get_poff() does no copy at all if you provide a linear 'skb'

Its really fast, I am really sorry you have wrong idea of what is going
on.

static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
                                       int len, void *buffer)
{
        int hlen = skb_headlen(skb);

        if (hlen - offset >= len)
                return skb->data + offset;


On the other hand GRO engine is way more expensive, now you mention it, we might
use the flow dissector to speed it.
