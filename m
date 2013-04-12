From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 02/11] ixgbe: Mask off check of frag_off as we only
 want fragment offset
Date: Fri, 12 Apr 2013 11:44:37 -0700
Message-ID: <1365792277.4459.67.camel@edumazet-glaptop>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	   <1365765866-15741-3-git-send-email-jeffrey.t.kirsher@intel.com>
	   <1365773328.4459.19.camel@edumazet-glaptop>
	  <1365774332.4459.24.camel@edumazet-glaptop> <51683884.2010509@intel.com>
	 <1365785511.4459.46.camel@edumazet-glaptop> <516850E4.8020504@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:39640 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164Ab3DLSoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 14:44:39 -0400
Received: by mail-pb0-f50.google.com with SMTP id jt11so1551876pbb.9
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 11:44:38 -0700 (PDT)
In-Reply-To: <516850E4.8020504@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 11:22 -0700, Alexander Duyck wrote:

> I appreciate the desire to reuse, and what I meant was that since igb
> and ixgbe both use essentially the same function I could move it to one
> central location and both of them could use it as well as any other low
> level drivers that need to just quickly parse the header out of a linear
> block of data.  I just don't feel __skb_get_poff really does what I am
> looking for since it assumes it is working with a skb, not just a linear
> block of data.

Big deal.

Filling skb->data/head/len/data_len/network_offset and you're done in 3
cycles or so.

We are constrained by the ~250 cycles the cpu has for free to fetch 2
cache lines from the received frame.

>   If it could get broken up somehow so that it, or at
> least pieces of it could just be used on linear blocks of data then I
> might be more interested in reusing it.

But this is not going to happen. Our skb code is able to deal with
multiple areas (skb->head and frags). We are not going to duplicate it
for linear skbs 'only'

Thats your call obviously to maintain your own code, but consider you
fix this quite incredible bug only now. (All TCP data segments have the
DF flag set, so you were not pulling tcp headers)
