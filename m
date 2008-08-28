From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [NET_NEXT PATCH 1/2] pkt_sched: Add multiqueue scheduler support
Date: Thu, 28 Aug 2008 09:07:20 -0700
Message-ID: <5f2db9d90808280907i747f4343j58c30e3020a1940d@mail.gmail.com>
References: <20080828011253.7909.5172.stgit@jtkirshe-mobile.jf.intel.com>
	 <20080828.012142.51698124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f29.google.com ([209.85.217.29]:59357 "EHLO
	mail-gx0-f29.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319AbYH1QHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 12:07:22 -0400
Received: by gxk10 with SMTP id 10so936229gxk.13
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2008 09:07:21 -0700 (PDT)
In-Reply-To: <20080828.012142.51698124.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It looks mostly fine.
>
> But I wonder how useful this "bands" parameter is.
> It behaves as follows:
>
> 1) "1" is always allowed, essentially non-multiqueue
> 2) ->real_num_tx_queues is always allowed
> 3) 0 means auto detect, which is also ->real_num_tx_queues
>
> Everything else is rejected.
>

Actually you give me too much credit.  I don't think bands even works
as a boolean, or at least it wasn't meant to.  It was supposed to be 0
or the number of queues which either way ends up the number of queues.
 It was a bit of leftover interface from the rr/prio configuration.  I
realized I left that in there when I was driving home last night but
by then it was too late.

I will probably just have it always default the number of bands to
always be real_num_tx_queues and save the user from having to enter
bands in the tc command line.

Thanks,

Alex
