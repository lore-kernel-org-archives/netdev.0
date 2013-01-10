From: Willy Tarreau <w@1wt.eu>
Subject: Re: tainted warnings with tcp splicing in 3.7.1
Date: Thu, 10 Jan 2013 20:43:19 +0100
Message-ID: <20130110194319.GB16165@1wt.eu>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan> <1357750898.27446.33.camel@edumazet-glaptop> <1357751372.27446.40.camel@edumazet-glaptop> <1357801149.27446.1142.camel@edumazet-glaptop> <20130110072136.GK9943@1wt.eu> <1357831787.27446.2168.camel@edumazet-glaptop> <1357834825.27446.2205.camel@edumazet-glaptop> <50EF06DD.7070207@hp.com> <1357843328.27446.2417.camel@edumazet-glaptop> <50EF0D2D.3040700@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christian Becker <c.becker@traviangames.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:38297 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753112Ab3AJTng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 14:43:36 -0500
Content-Disposition: inline
In-Reply-To: <50EF0D2D.3040700@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2013 at 10:49:17AM -0800, Rick Jones wrote:
> On 01/10/2013 10:42 AM, Eric Dumazet wrote:
> >Can we use zero copy for the sender as well (sendfile() or vmsplice()) ?
> 
> Not at present.  The TCP_SENDFILE test has not been "migrated" and there 
> is no corresponding sendfile() test in the omni code, so the attempt to 
> enable copy-avoidance won't "take."

Note that in my httpterm server, I'm using tee+splice(). I had a problem
with vmsplice() in the past, I don't remember which one.

For the "inject" http client, I'm using recv(MSG_TRUNC) which is always
faster than splice() and does the job well, considering that the goal is
to count and destroy data very fast.

By combining them both on the same machine over the loopback, I see
70 Gbps on a core-2 duo 2.66 GHz. These are obviously not real gigs,
but at least it shows what the network stack can do when we remove
memory copies !

Regards,
Willy
