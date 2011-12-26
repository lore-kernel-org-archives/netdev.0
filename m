From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet: fix dev refcnt leak when bind fail
Date: Mon, 26 Dec 2011 15:15:47 -0500 (EST)
Message-ID: <20111226.151547.564743129441895726.davem@davemloft.net>
References: <CAPgLHd9KNN81cPYv3bGzoBwUtnJSAoX4NN0Fh+wNgoHE_t7d=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116Ab1LZUPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 15:15:49 -0500
In-Reply-To: <CAPgLHd9KNN81cPYv3bGzoBwUtnJSAoX4NN0Fh+wNgoHE_t7d=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 26 Dec 2011 17:02:59 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> If bind is fail such as bind is called after set PACKET_FANOUT
> sock option, the dev refcnt will leak.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The device pointer is stored in ->prot_hook.dev

Therefore, it will be released at the latest in packet_release() or
earlier if another bind() attempt is done on the socket.

There is no leak here as far as I can see.
