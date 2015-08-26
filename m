From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: mmap: fix status setting in skb destructor
Date: Tue, 25 Aug 2015 20:22:03 -0700 (PDT)
Message-ID: <20150825.202203.408221873735724462.davem@davemloft.net>
References: <55CDBC84.8020605@iogearbox.net>
	<55CDC51D.1060204@iogearbox.net>
	<20150820070733.GA3711@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de
To: chamaken@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbbHZDWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 23:22:04 -0400
In-Reply-To: <20150820070733.GA3711@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Date: Thu, 20 Aug 2015 16:07:33 +0900

> I don't know the intension of setting VALID status in the skb
> destructor. But I think it need to be set UNUSED status in case of
> error then release skb, or rx ring might be filled with RESERVED
> frames.
> 
> Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>

I think the idea is to have the user process this "zero length" frame
and advance the status itself.

I think it is probably racy and problematic to have the kernel set a
frame's state to UNUSED.  It is not a valid state transition for the
kernel side of RX ring processing.

Only the user can safely release ring entries back to the kernel.
