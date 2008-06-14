From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sat, 14 Jun 2008 14:45:36 -0400
Message-ID: <1213469136.7149.36.camel@localhost>
References: <20080613163700.GA25860@2ka.mipt.ru>
	 <20080613164110.GB26166@2ka.mipt.ru> <20080614021547.GC32232@shareable.org>
	 <20080614065616.GA32585@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080614065616.GA32585@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2008-06-14 at 10:56 +0400, Evgeniy Polyakov wrote:
> > That sounds great, but what do you mean by 'novel'?  Don't other
> > modern network filesystems use asynchronous requests and replies in
> > some form?  It seems like the obvious thing.
> 
> Maybe it was a bit naive though :)
> But I checked lots of implementation, all of them use send()/recv()
> approach. NFSv4 uses a bit different, but it is a cryptic, and at least
> from its names it is not clear:
> like nfs_pagein_multi() -> nfs_pageio_complete() -> add_stats. Presumably
> we add stats when we have data handy...

You're confusing write gathering with asynchronous I/O...

NFS attempts to send multiple contiguous pages in one I/O request, and
so it has a mechanism for collecting them and dispatching the I/O as
soon as we have enough pages for an RPC call.

The actual RPC call is then handled by the sunrpc layer and is done
fully asynchronously using non-blocking I/O.

  Trond

