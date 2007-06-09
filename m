From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] RFC: have tcp_recvmsg() check kthread_should_stop() and
 treat it as if it were signalled
Date: Sat, 9 Jun 2007 07:08:26 -0400
Message-ID: <20070609070826.7bd3480c.jlayton@redhat.com>
References: <20070608123527.9b4cdafe.jlayton@redhat.com>
	<E1HwpmG-0008LW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-cifs-client@lists.samba.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1HwpmG-0008LW-00@gondolin.me.apana.org.au>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 09 Jun 2007 11:30:04 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Please cc networking patches to netdev@vger.kernel.org.
> 
> Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > The following patch is a first stab at removing this need. It makes it
> > so that in tcp_recvmsg() we also check kthread_should_stop() at any
> > point where we currently check to see if the task was signalled. If
> > that returns true, then it acts as if it were signalled and returns to
> > the calling function.
> 
> This just doesn't seem to fit.  Why should networking care about kthreads?
> 
> Perhaps you can get kthread_stop to send a signal instead?
> 

The problem there is that we still have to make the kthread let signals
through. The nice thing about this approach is that we can make the
kthread ignore signals, but still allow it to break out of kernel_recvmsg
when a kthread_stop is done.

Though I will confess that you have a point about this feeling like a
layering violation...

-- 
Jeff Layton <jlayton@redhat.com>
