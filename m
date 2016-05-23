From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v5 2/2] skb_array: ring test
Date: Mon, 23 May 2016 23:52:47 +0300
Message-ID: <20160523235014-mutt-send-email-mst@redhat.com>
References: <1464000201-15560-1-git-send-email-mst@redhat.com>
 <1464000201-15560-3-git-send-email-mst@redhat.com>
 <20160523150918.2c58fa7d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160523150918.2c58fa7d@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2016 at 03:09:18PM +0200, Jesper Dangaard Brouer wrote:
> On Mon, 23 May 2016 13:43:46 +0300
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > Add ringtest based unit test for skb array.
> >
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  tools/virtio/ringtest/skb_array.c | 167 ++++++++++++++++++++++++++++++++++++++
> >  tools/virtio/ringtest/Makefile    |   4 +-
> 
> Patch didn't apply cleanly to Makefile, as you also seems to have
> "virtio_ring_inorder", I manually applied it.
> 
> I chdir to tools/virtio/ringtest/ and I could compile "skb_array",
> BUT how do I use it??? (the README is not helpful)
> 
> What is the "output", are there any performance measurement results?

First, if it completes successfully this means it completed
a ton of cycles without errors. It caches any missing barriers
which aren't nops on your system.

Second - use perf.

E.g. simple perf stat will measure how long does it take to execute.
there's a script that runs it on different CPUs,
so I normally do:

sh run-on-all.sh perf stat -r 5 ./skb_array


> > diff --git a/tools/virtio/ringtest/Makefile b/tools/virtio/ringtest/Makefile
> > index 6ba7455..87e58cf 100644
> > --- a/tools/virtio/ringtest/Makefile
> > +++ b/tools/virtio/ringtest/Makefile
> > @@ -1,6 +1,6 @@
> >  all:
> >  
> > -all: ring virtio_ring_0_9 virtio_ring_poll virtio_ring_inorder
> > +all: ring virtio_ring_0_9 virtio_ring_poll virtio_ring_inorder skb_array
>                                               ^^^^^^^^^^^^^^^^^^^
> >  
> >  CFLAGS += -Wall
> >  CFLAGS += -pthread -O2 -ggdb
> > @@ -8,6 +8,7 @@ LDFLAGS += -pthread -O2 -ggdb
> >  
> >  main.o: main.c main.h
> >  ring.o: ring.c main.h
> > +skb_array.o: skb_array.c main.h ../../../include/linux/skb_array.h
> >  virtio_ring_0_9.o: virtio_ring_0_9.c main.h
> >  virtio_ring_poll.o: virtio_ring_poll.c virtio_ring_0_9.c main.h
> >  virtio_ring_inorder.o: virtio_ring_inorder.c virtio_ring_0_9.c main.h
> > @@ -15,6 +16,7 @@ ring: ring.o main.o
> >  virtio_ring_0_9: virtio_ring_0_9.o main.o
> >  virtio_ring_poll: virtio_ring_poll.o main.o
> >  virtio_ring_inorder: virtio_ring_inorder.o main.o
>    ^^^^^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^^
> > +skb_array: skb_array.o main.o
> >  clean:
> >  	-rm main.o
> >  	-rm ring.o ring
> 
> 
> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
