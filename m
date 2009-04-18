From: David Miller <davem@davemloft.net>
Subject: Re: What is lock_sock() before skb_free_datagram() for?
Date: Sat, 18 Apr 2009 01:35:38 -0700 (PDT)
Message-ID: <20090418.013538.126788034.davem@davemloft.net>
References: <200904181704.FDC21361.FQLOFHOOSVFtMJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43297
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752949AbZDRIfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 04:35:47 -0400
In-Reply-To: <200904181704.FDC21361.FQLOFHOOSVFtMJ@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 18 Apr 2009 17:04:01 +0900

> Hello.
> 
> udp_recvmsg() and udpv6_recvmsg() call skb_free_datagram() with 
> lock_sock().
> But raw_recvmsg() and rawv6_recvmsg() call skb_free_datagram() 
> without
> lock_sock().
> Is it OK?

UDP does global socket memory accounting, and supports transient
state between sendmsg() calls via MSG_MORE, so it needs
locking.

RAW does not support those things, so doesn't need the locking.
