From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered EPOLLOUT events get missed for TCP sockets
Date: Thu, 20 Sep 2007 15:24:53 -0700 (PDT)
Message-ID: <549830.78824.qm@web53705.mail.re2.yahoo.com>
References: <Pine.LNX.4.64.0709201048290.8897@alien.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Nagendra Tomar <tomer_iisc@yahoo.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Davide Libenzi <davidel@xmailserver.org>,
	Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756093AbXITWZZ@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0709201048290.8897@alien.or.mcafeemobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Davide Libenzi <davidel@xmailserver.org> wrote:

> 
> Unfortunately f_op->poll() does not let the caller to specify the events 
> it's interested in, that would allow to split send/recevie wait queues and 
> better detect read/write cases.
> The detection of a waitqueue_active(->sk_wr_sleep) would work fine in 
> detecting is someone is actually waiting for a write, w/out the false 
> positives triggered by the read-waiters.
> That would be a very sane thing to do, but would require a big&dumb change 
> to all the ->poll around (that could be automated by a script - devices 
> not caring about the events hint can just continue to use the single queue 
> like they currently do), and a more critical and gradual change of all the 
> devices that wants to take advantage of it.
> That way, no more magic bits are needed, and a simple waitqueue_active() 
> would tell you if someone is waiting for write-space events.
> 

I like this.





      ___________________________________________________________ 
To help you stay safe and secure online, we've developed the all new Yahoo! Security Centre. http://uk.security.yahoo.com
