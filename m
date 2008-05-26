From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 26 May 2008 19:32:14 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805261926260.24924@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <Pine.LNX.4.64.0805261550340.16829@wrl-59.cs.helsinki.fi>
 <20080526135940.GB24870@elte.hu> <20080526141252.GA31352@elte.hu>
 <Pine.LNX.4.64.0805261745010.16829@wrl-59.cs.helsinki.fi> <20080526162328.GA9089@elte.hu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1441707997-1211819534=:24924"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45246 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbYEZQcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 12:32:16 -0400
In-Reply-To: <20080526162328.GA9089@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1441707997-1211819534=:24924
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 26 May 2008, Ingo Molnar wrote:

> 
> * Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > On Mon, 26 May 2008, Ingo Molnar wrote:
> > 
> > > there's a hung distcc task on the system, waiting for socket action 
> > > forever:
> > > 
> > >   [root@europe ~]# strace -fp 19578
> > >   Process 19578 attached - interrupt to quit
> > >   select(5, NULL, [4], [4], {82, 90000} <unfinished ...>
> > 
> > Hmm, readfds is NULL isn't it?!? Are you sure you straced the right 
> > process?
> 
> yes, i'm stracing the task that is hung unexpectedly.

But that wasn't the receiving process? (I didn't quickly find into which 
direction distcc ports go, so I couldn't confirm this). If you still have 
that situation at hand, could you check which is the receiving process 
(e.g., using netstat -p, the end which has Recv-Q is the right one) and 
where it's stuck?

> > > disturbing that task via strace did not change the state of the 
> > > socket - and that's not unexpected as it's a select(). [TCP state 
> > > might be affected if strace impacted a recvmsg or a sendmsg wait 
> > > directly.]
> > 
> > I fail to understand this paragraph due to excessive negation... :-)
> 
> i mean, sometimes a TCP connection can get 'unstuck' if you strace a 
> task - that is because the TCP related syscall the task sits in gets 
> interrupted. But in this case it's select() which doesnt explicitly take 
> the socket, doesnt do any tcp_push_pending_frames() processing, etc. - 
> it just its on the socket waitqueue AFAICS. And that's expected.

This is not in the sender end at all. It's correct behavior of the flow 
control to stop the sender until more room is made available by the 
reading end. Thus push_pending_frames couldn't send anything.

...It may still be that the receiving process is stuck due to the non-net 
related changes you have there.

-- 
 i.
---696208474-1441707997-1211819534=:24924--
