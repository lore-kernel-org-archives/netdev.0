From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next] net: qualcomm: rmnet: Support recycling frames
 to real device
Date: Fri, 27 Oct 2017 16:22:12 -0600
Message-ID: <e5781ccadd670fd3ddf07f0e3fff1256@codeaurora.org>
References: <1509136208-14768-1-git-send-email-subashab@codeaurora.org>
 <CAKgT0Ufnupf=fUbivLWrMhmfkcx4f0ApZ7gS_9VK7P7J8zB1aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58842 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751617AbdJ0WWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 18:22:13 -0400
In-Reply-To: <CAKgT0Ufnupf=fUbivLWrMhmfkcx4f0ApZ7gS_9VK7P7J8zB1aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This doesn't make sense to me, maybe I am missing something. What
> "real device" is setting the skb->destructor() and doing it to somehow
> handle recycling? The only driver I can find that is setting
> skb->desctructor() is the Chelsio drivers, and they appear to be using
> it to just clean-up DMA mappings in their transmit path.
> 
> Thanks.
> 
> - Alex

Hi Alex

The real device will have a pool of skbs and mark them as unused on
initialization. It will use these skbs to copy data from hardware and
pass them onto rmnet after marking them as used. Once rmnet is done
processing, the callback of the real device set in the skb_destructor
is invoked and the skb is set as unused and can be used again for
copying data.

There are no drivers setting the skb->destructor() in receive path
upstream as of now but the plan is to get them there.

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project
