From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Sat, 18 Apr 2015 03:20:41 +0900
Message-ID: <201504180320.CFG26062.FtSJLOOQOFVFMH@I-love.SAKURA.ne.jp>
References: <20150417173754.GC16743@htj.duckdns.org>
	<201504180243.IDB78159.tFVOOFQFSOHLMJ@I-love.SAKURA.ne.jp>
	<20150417174522.GD16743@htj.duckdns.org>
	<201504180303.GAB26011.OLJFSMVFFOHtOQ@I-love.SAKURA.ne.jp>
	<20150417180732.GF16743@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150417180732.GF16743@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun Heo wrote:
> On Sat, Apr 18, 2015 at 03:03:46AM +0900, Tetsuo Handa wrote:
> > packet will be sufficient for finding out whether the packets were lost and/or
> > reordered in flight.
> > 
> >   printk("Hello");
> >    => netconsole sends "00000000 Hello" using UDP
> >   printk("netconsole");
> >    => netconsole sends "00000001 netconsole" using UDP
> >   printk("world\n");
> >    => netconsole sends "00000002 world\n" using UDP
> > 
> > It might be nice to allow administrator to prefix a sequence number
> > to netconsole messages for those who are using special receiver
> > program (e.g. ncrx) which checks that sequence number.
> 
> That said, this is pretty much what the first 12 patches do (except
> for the last printk patch, which can be taken out).  We already have
> sequencing and established format to expose them to userland - try cat
> /dev/kmsg, which btw is what local loggers on modern systems use
> anyway.  Why introduce netconsole's own version of metadata?

I didn't mean to introduce netconsole's own version of metadata.
I meant we don't need to implement in-kernel retry logic.

If we can assume that scheduler is working, adding a kernel thread that
does

  while (1) {
      read messages with metadata from /dev/kmsg
      send them using UDP network
  }

might be easier than modifying netconsole module.

> 
> Thanks.
> 
> -- 
> tejun
> 
