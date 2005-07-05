From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Tue, 05 Jul 2005 14:22:10 -0700 (PDT)
Message-ID: <20050705.142210.14973612.davem@davemloft.net>
References: <20050705134805.GH16076@postel.suug.ch>
	<42CAAE2F.5070807@cosmosbay.com>
	<20050705173411.GK16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050705173411.GK16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 5 Jul 2005 19:34:11 +0200

> Do as you wish, I don't feel like argueing about micro optimizations.

I bet the performance gain really comes from the mispredicted
branches in the loop.

For loops of fixed duration, say, 5 or 6 iterations or less, it
totally defeats the branch prediction logic in most processors.
By the time the chip moves the I-cache branch state to "likely"
the loop has ended and we eat a mispredict.

I think the original patch is OK, hand unrolling the loop in
the C code.  Adding -funroll-loops to the CFLAGS has lots of
implications, and in particular the embedded folks might not
be happy with some things that result from that.

So I'll apply the original unrolling patch for now.
