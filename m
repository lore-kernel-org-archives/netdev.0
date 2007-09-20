From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered EPOLLOUT
 events get missed for TCP sockets
Date: Thu, 20 Sep 2007 10:56:14 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709201048290.8897@alien.or.mcafeemobile.com>
References: <331107.71046.qm@web53704.mail.re2.yahoo.com> <46F20F24.1020900@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nagendra Tomar <tomer_iisc@yahoo.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759324AbXITR42@vger.kernel.org>
In-Reply-To: <46F20F24.1020900@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Sep 2007, Eric Dumazet wrote:

> Does it means that with your patch each ACK on a ET managed socket will
> trigger an epoll event   ?
> 
> Maybe your very sensitive high throuput appication needs to set a flag or
> something at socket level to ask for such a behavior.
> 
> The default should stay as is. That is an event should be sent only if someone
> cared about the wakeup.

Unfortunately f_op->poll() does not let the caller to specify the events 
it's interested in, that would allow to split send/recevie wait queues and 
better detect read/write cases.
The detection of a waitqueue_active(->sk_wr_sleep) would work fine in 
detecting is someone is actually waiting for a write, w/out the false 
positives triggered by the read-waiters.
That would be a very sane thing to do, but would require a big&dumb change 
to all the ->poll around (that could be automated by a script - devices 
not caring about the events hint can just continue to use the single queue 
like they currently do), and a more critical and gradual change of all the 
devices that wants to take advantage of it.
That way, no more magic bits are needed, and a simple waitqueue_active() 
would tell you if someone is waiting for write-space events.



- Davide
