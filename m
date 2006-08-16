From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH?] tcp and delayed acks
Date: Thu, 17 Aug 2006 02:39:57 +0400
Message-ID: <20060816223957.GA13157@ms2.inr.ac.ru>
References: <20060816205532.GF9519@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:12686 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932307AbWHPWkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 18:40:19 -0400
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20060816205532.GF9519@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> send out any delayed ACKs when it is clear that the receiving process is 
> waiting for more data?

It has just be done in tcp_cleanup_rbuf() a few lines before your chunk.
There is some somplex condition to be satisfied there and it is
impossible to relax it any further.

I do not know what is wrong in your case, check what of conditions
in tcp_cleanup_rbuf() was not satisfied. Or just tcpdump a little.

BTW what "buffer" do you mean? SO_SNDBUF? SO_RCVBUF? Something else?
TCP tries to tune itself to weird buffer sizes to allow to have
at least 2 segments in flight exactly to address the problem with delayed
ACKs, but it is quite easy to confuse those heuristics.

Alexey
