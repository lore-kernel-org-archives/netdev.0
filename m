From: "David S. Miller" <davem@redhat.com>
Subject: Re: TCP hang in timewait processing
Date: Sun, 28 Mar 2004 01:35:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040328013549.58c32b63.davem@redhat.com>
References: <40660DF7.9090806@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bkon@us.ibm.com, jgrimm@us.ibm.com, jgarvey@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <40660DF7.9090806@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 27 Mar 2004 15:27:51 -0800
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Any ideas, pointers would be very much appreciated!

One thing that makes timewait bucket garbage collection interesting
is that the node can be reached from two spots, the death row list
and the TCP hash chains via packet input processing.

So you have to see if scenerios like the following are possible:

1) TW death worker thread choose tw X to be killed, drops tw_death_lock
2) packet input hits tw X, packet is reset which kills the tw
3) packet input thus tries to remove tw X from the death row list
   too and put it

You get the idea.

We had a similar bug recently in the 2.6.x tree but that was due to
a bug in the tw-kill-via-worker-thread code which is not in 2.4.x unless
someone patched it into the 2.4.x tree you are using :-)
