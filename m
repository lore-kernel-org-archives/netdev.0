From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Sat, 18 Apr 2015 03:03:46 +0900
Message-ID: <201504180303.GAB26011.OLJFSMVFFOHtOQ@I-love.SAKURA.ne.jp>
References: <20150417162826.GB16743@htj.duckdns.org>
	<20150417.131712.1245246947203158168.davem@davemloft.net>
	<20150417173754.GC16743@htj.duckdns.org>
	<201504180243.IDB78159.tFVOOFQFSOHLMJ@I-love.SAKURA.ne.jp>
	<20150417174522.GD16743@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150417174522.GD16743@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun Heo wrote:
> > printk() cannot wait for ack. Trying to wait for ack would break something.
> > How can you transmit subsequent kernel messages which failed to enqueue
> > due to waiting for ack for previous kernel messages?
> 
> Well, if log buffer overflows and the messages aren't at the logging
> target yet, they're lost.  It's the same as doing dmesg on localhost,
> isn't it?  This doesn't have much to do with where the reliability
> logic is implemented and is exactly the same with local logging too.

If you tolerate loss of kernel messages, adding sequence number to each UDP
packet will be sufficient for finding out whether the packets were lost and/or
reordered in flight.

  printk("Hello");
   => netconsole sends "00000000 Hello" using UDP
  printk("netconsole");
   => netconsole sends "00000001 netconsole" using UDP
  printk("world\n");
   => netconsole sends "00000002 world\n" using UDP

It might be nice to allow administrator to prefix a sequence number
to netconsole messages for those who are using special receiver
program (e.g. ncrx) which checks that sequence number.

> 
> Thanks.
> 
> -- 
> tejun
> 
