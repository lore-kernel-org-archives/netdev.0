From: David Miller <davem@davemloft.net>
Subject: Re: Sending short raw packets using sendmsg() broke
Date: Fri, 26 Feb 2016 12:46:45 -0500 (EST)
Message-ID: <20160226.124645.2123990166666725876.davem@davemloft.net>
References: <20160225.152628.1230785666614750970.davem@davemloft.net>
	<1456497874.7064.7.camel@linux.intel.com>
	<CAF=yD-JOQZZnU6XE9FhEVbxstKmsB-ds58e5v678SiO24VV0+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@linux.intel.com, hessu@hes.iki.fi, netdev@vger.kernel.org,
	willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754324AbcBZRqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 12:46:47 -0500
In-Reply-To: <CAF=yD-JOQZZnU6XE9FhEVbxstKmsB-ds58e5v678SiO24VV0+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri, 26 Feb 2016 12:33:13 -0500

> Right. The simplest, if hacky, fix is to add something along the lines of
> 
>   static unsigned short netdev_min_hard_header_len(struct net_device *dev)
>   {
>       if (unlikely(dev->type ==ARPHDR_AX25))
>         return AX25_KISS_HEADER_LEN;
>       else
>         return dev->hard_header_len;
>   }
> 
> Depending on how the variable encoding scheme works, a basic min
> length check may still produce buggy headers that confuse the stack or
> driver. I need to read up on AX25. If so, then extending header_ops
> with an optional validate() function is a more generic approach of
> checking header sanity.

I suspect we will need some kind of header ops for this.
