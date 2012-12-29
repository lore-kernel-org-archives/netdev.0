From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Date: Sat, 29 Dec 2012 11:34:34 +0000
Message-ID: <20121229113434.GA13336@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20121228070652.GA6292@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Voellmy <andreas.voellmy@yale.edu>,
	viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
	"Junchang(Jason) Wang" <junchang.wang@yale.edu>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121228070652.GA6292@dcvr.yhbt.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Wong <normalperson@yhbt.net> wrote:
> Eric Wong <normalperson@yhbt.net> wrote:
> > I'm finding ppoll() unexpectedly stuck when waiting for POLLIN on a
> > local TCP socket.  The isolated code below can reproduces the issue
> > after many minutes (<1 hour).  It might be easier to reproduce on
> > a busy system while disk I/O is happening.
> 
> Ugh, I can't seem to reproduce this anymore...  Will try something
> else tomorrow.

The good news is I'm not imagining this...

The bad news is the issue is real and took a long time to reproduce
again.  This issue happens even without preempt, and without
tcp_low_latency on 3.7.1

While running `toosleepy', I also needed to run heavy (not loopback)
network and disk activity (several USB, SATA, and eSATA drives
simultaneously) for many hours before hitting this.

Hopefully this report is helpful in solving the issue.  Looking in at
the various pieces in net and select/poll paths, there's several
references to race conditions in the comments so this is hopefully
familiar territory to someone here...
