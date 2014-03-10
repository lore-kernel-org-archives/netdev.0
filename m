From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] unix: add read side socket memory accounting for dgram sockets
Date: Mon, 10 Mar 2014 22:04:09 +0100
Message-ID: <20140310210409.GI5493@order.stressinduktion.org>
References: <20140304201336.GB26307@order.stressinduktion.org> <20140304.153732.1314382655798460205.davem@davemloft.net> <20140310010754.GE5493@order.stressinduktion.org> <20140310.162756.2102404684106170700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	eric.dumazet@gmail.com, xiyou.wangcong@gmail.com, dan@mindstab.net,
	tmorvai@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54739 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbaCJVEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 17:04:10 -0400
Content-Disposition: inline
In-Reply-To: <20140310.162756.2102404684106170700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Mon, Mar 10, 2014 at 04:27:56PM -0400, David Miller wrote:
> > First the unconnected send/reply benchmark, which look good.
> > 
> > /home/hannes/netperf-2.6.0/src/netperf -t  DG_RR -- -r 1,1
> > 
> > === Unpatched net-next: ===
> > DG REQUEST/RESPONSE TEST
> > Local /Remote
> > Socket Size   Request  Resp.   Elapsed  Trans.
> > Send   Recv   Size     Size    Time     Rate
> > bytes  Bytes  bytes    bytes   secs.    per sec
> > 
> > 212992 212992 1        1       10.00    23587.28
> > 4608   2304
> > 
> > === Patched net-next: ===
> > DG REQUEST/RESPONSE TEST
> > Local /Remote
> > Socket Size   Request  Resp.   Elapsed  Trans.
> > Send   Recv   Size     Size    Time     Rate
> > bytes  Bytes  bytes    bytes   secs.    per sec
> > 
> > 212992 212992 1        1       10.00    21607.50
> > 4608   2304
> 
> If I read those transaction rate numbers correctly, it's slowing
> down by more then %8.  I'm not so sure that looks "good" to me.

You haven't seen the other benchmarks before I fixed the wakeup. ;)

(I should really have done more benchmarks before, I only was concerened
about the "correctness" issue.)

Ok, sure, a performance drop is clearly visible, I have to admit, even
though I don't know if lot's of people use this style of communication.

> > I couldn't do the parameterless netperf DG_STREAM benchmarks, because
> > netserver unconditionally sets SO_RCVBUF to 0 and such the clamps this value
> > to SOCK_MIN_RCVBUF. The sender cannot send netperf's normal packet size
> > through the socket. In case there are other applications out there,
> > are we allowed to break them?
>  ...
> > The important question for me is if we can assume applications already
> > setting SO_RCVBUF to some minimal value and because of this not receiving
> > packets being buggy and ignore them or do we need to introduce some way
> > around this?
> 
> I think if it works currently, the risk of breaking a lot of things is simply
> too high to change this.

Yes, it currently works.

I have to think more about this, but the only solutions which I came up
with is adding more special cases for connected dgram sockets etc. and
that cannot be the solution either... (especially because even connected
sockets can communicate with other sockets if msg->msg_name is specified).

Thanks,

  Hannes
