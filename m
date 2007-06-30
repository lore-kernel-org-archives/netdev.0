From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] CIFS: make cifsd (more)
Date: Sat, 30 Jun 2007 09:42:09 +0100
Message-ID: <20070630084209.GA21186@infradead.org>
References: <524f69650706251525g7b17ea02o5fb3e637615fe542@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, jlayton@redhat.com,
	linux-kernel@vger.kernel.org, linux-cifs-client@lists.samba.org,
	netdev@vger.kernel.org
To: Steve French <smfrench@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <524f69650706251525g7b17ea02o5fb3e637615fe542@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 25, 2007 at 05:25:00PM -0500, Steve French wrote:
> Jeff,
> Not seeing any objections to your revised approach (to not allowing
> signals for cifsd kernel thread), I just merged something similar to
> your patch to the cifs-2.6.git tree (also fixed some nearby lines that
> went past 80 columns).

Ok, I'm back to this.

As I said mixing force_sig with the kthread infrastructure is a bad idea.
The proper short-term (aka 2.6.22) fix is to revert the kthread conversion
for this particular thread.  Just go back to what worked before.

Now the right fix is a lot more complicated and involved:

	Stop using blocking recvmsg (or read) in kernel threads!

If you look at what the other consumers of networking reads from kernel
threads do is they either use tcp_read_sock and hooks into the sk_ callbacks
which would be nice for high performance reads in cifs aswell, but probably
not the demultiplexer thread, or they use MSG_DONTWAIT to avoid this problems
and deal with the blocking behaviour on a higher level.
