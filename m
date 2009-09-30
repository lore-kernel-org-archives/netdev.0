From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Splice on blocking TCP sockets again..
Date: Tue, 29 Sep 2009 18:48:20 -0600
Message-ID: <20090930004820.GC19540@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Volker Lendecke <vl@samba.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 139-142-54-143.atc.vaillant.ca ([139.142.54.143]:51293 "EHLO
	quartz.edm.orcorp.ca" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753821AbZI3B0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 21:26:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

I saw your patch from January regarding splicing on blocking sockets,
and I wondered what ever happened to it?

http://lkml.org/lkml/2009/1/13/507

It doesn't look like it has been applied.. I see the patch thread died
at davem's comments?

I have run into exactly the same problem as Samba, where I'd like the
TCP socket to be blocking, and the pipe to be non blocking ...

As it stands, 
  splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE); 
causes a random endless block and
  splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK);
will return 0 immediately if the TCP buffer is empty.

FWIW, it looks like samba has a splice code now, but doesn't enable it
due to this issue?

http://git.samba.org/?p=samba.git;a=history;f=source3/lib/recvfile.c;h=ea0159642137390a0f7e57a123684e6e63e47581;hb=HEAD

Thanks,
Jason
