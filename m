From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 09 Nov 2010 14:59:19 +0100
Message-ID: <1289311159.17448.9.camel@traveldev.cxnet.dk>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:50698 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820Ab0KIOHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 09:07:24 -0500
In-Reply-To: <1289228785.2820.203.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-11-08 at 16:06 +0100, Eric Dumazet wrote:
...
> > > > > I noticed that the loopback performance has gotten quite bad:
> > > > > 
> > > > > http://www.phoronix.com/scan.php?page=article&item=linux_2612_2637&num=6
> >

> CC netdev, if you dont mind.

No problem :-)

> Their network test is basically :
> 
> netcat -l 9999 >/dev/null &
> time dd if=/dev/zero bs=1M count=10000 | netcat  127.0.0.1 9999

Should it not be:
 netcat -l -p 9999 >/dev/null &

When I run the commands "dd | netcat", netcat never finish/exits, I have
to press Ctrl-C to stop it.  What am I doing wrong? Any tricks?

"dd" reports 17.54 sec, and but the "time" measurement cannot be uses as
the netcat just hangs/waits for more data...

time dd if=/dev/zero bs=1M count=10000 | netcat 127.0.0.1 9999
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB) copied, 17,5419 s, 598 MB/s

When I run the commands, I see 261682 context switches per sec...

This quick test were on a Core i7 920 using kernel
2.6.32-rc3-net-next-dev-mp2t.

-- 
Jesper Dangaard Brouer
ComX Networks A/S

