From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: sender throttling for unreliable protocols not garuanteed? (different units in sock->wmem_alloc and net_devive->tx_queue_len)
Date: Fri, 11 Aug 2006 18:07:46 +0400
Message-ID: <20060811140746.GA9209@ms2.inr.ac.ru>
References: <Pine.LNX.4.64.0608111418260.10347@nettc.informatik.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:4766 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751139AbWHKOIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 10:08:32 -0400
To: Steffen Maier <smaier@users.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0608111418260.10347@nettc.informatik.uni-stuttgart.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> I'd be interested in any opinions on the above mentioned effect.

Everything is right, it is exactly how it works.

Well, use another qdisc, which counts in bytes rather than in frames
(f.e. bfifo)

Set sndbuf small enough.

And if sndbuf*#senders is still too large, you have to use fair queueing,
sfq is quite good for this purpose.

Alexey
