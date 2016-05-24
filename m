From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v5 2/2] skb_array: ring test
Date: Tue, 24 May 2016 12:28:09 +0200
Message-ID: <20160524122809.140f7020@redhat.com>
References: <1464000201-15560-1-git-send-email-mst@redhat.com>
	<1464000201-15560-3-git-send-email-mst@redhat.com>
	<20160523150918.2c58fa7d@redhat.com>
	<20160523235014-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160523235014-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 May 2016 23:52:47 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Mon, May 23, 2016 at 03:09:18PM +0200, Jesper Dangaard Brouer wrote:
> > On Mon, 23 May 2016 13:43:46 +0300
> > "Michael S. Tsirkin" <mst@redhat.com> wrote:
> >   
> > > Add ringtest based unit test for skb array.
> > >
> > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > ---
> > >  tools/virtio/ringtest/skb_array.c | 167 ++++++++++++++++++++++++++++++++++++++
> > >  tools/virtio/ringtest/Makefile    |   4 +-  
> > 
> > Patch didn't apply cleanly to Makefile, as you also seems to have
> > "virtio_ring_inorder", I manually applied it.
> > 
> > I chdir to tools/virtio/ringtest/ and I could compile "skb_array",
> > BUT how do I use it??? (the README is not helpful)
> > 
> > What is the "output", are there any performance measurement results?  
> 
> First, if it completes successfully this means it completed
> a ton of cycles without errors. It caches any missing barriers
> which aren't nops on your system.

I applied these patches on net-next (at commit 07b75260e) and the
skb_array test program never terminates.   Strangely if I use your git
tree[1] (on branch vhost) the program does terminate... I didn't spot
the difference.
 
> Second - use perf.

I do like perf, but it does not answer my questions about the
performance of this queue. I will code something up in my own
framework[2] to answer my own performance questions.

Like what is be minimum overhead (in cycles) achievable with this type
of queue, in the most optimal situation (e.g. same CPU enq+deq cache hot)
for fastpath usage.

Then I also want to know how this performs when two CPUs are involved.
As this is also a primary use-case, for you when sending packets into a
guest.


> E.g. simple perf stat will measure how long does it take to execute.
> there's a script that runs it on different CPUs,
> so I normally do:
>
> sh run-on-all.sh perf stat -r 5 ./skb_array

I recommend documenting this in the README file in the same dir ;-)

[1] https://git.kernel.org/cgit/linux/kernel/git/mst/vhost.git/log/?h=vhost
[2] https://github.com/netoptimizer/prototype-kernel
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
