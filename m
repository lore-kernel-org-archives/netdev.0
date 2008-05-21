From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] Fix frag list handling in TCP splice receive
Date: Wed, 21 May 2008 11:05:03 +0300
Message-ID: <200805211105.03947.opurdila@ixiacom.com>
References: <200805171636.07443.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:2459 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S934931AbYEUIGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 04:06:13 -0400
In-Reply-To: <200805171636.07443.opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 17 May 2008, Octavian Purdila wrote:
> If an skb does not have fragments but its fragment list is not empty (can
> happen, via LRO at least) and a previous tcp_read_sock has consumed
> the linear part of the skb then __skb_splice_bits:
>
> (a) incorrectly reports an error and
>
> (b) forgets to update the offset to account for the linear part
>
> Any of the two problems will cause the subsequent __skb_splice_bits call
> (the one that handles the fragment list skbs) to either skip data, or, if
> the unadjusted offset is greater then the size of the next skb, make
> tcp_splice_read loop forever.
>

Hi,

Any comments, please?

Patch for 2.6.25 is here:

http://www.spinics.net/lists/netdev/msg63541.html

Thanks,
tavi
