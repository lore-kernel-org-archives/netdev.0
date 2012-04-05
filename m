From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Thu, 5 Apr 2012 23:34:41 +0900
Message-ID: <201204052334.EBI17103.OOFOSLFQJVHFtM@I-love.SAKURA.ne.jp>
References: <CA+1xoqcAXyh306=2=QKWyM3BE44=MT+nsuRQn5YLOLgbtZqicA@mail.gmail.com>
	<CA+1xoqe1Wc_uifrKsko6hu+py9Ahz3Q0p1tRxup09jmh2NZ1rw@mail.gmail.com>
	<201204011221.GAG51016.JQFSFFOtLOMVHO@I-love.SAKURA.ne.jp>
	<CA+1xoqe+T=iUtUeFdeqmRvMZ7TMCgkLs_1QYv-4YNtn-jCoMCQ@mail.gmail.com>
	<201204052329.EBH52139.FFOLQMOJSVHOFt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oleg@redhat.com, eric.dumazet@gmail.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com,
	penguin-kernel@I-love.SAKURA.ne.jp
To: levinsasha928@gmail.com, garlick@llnl.gov, ericvh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204052329.EBH52139.FFOLQMOJSVHOFt@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa wrote:
> Good. -512 is -ERESTARTSYS, and this hang occurs after -ERESTARTSYS is
> returned. It indicates that c->trans_mod->request() is interrupted by signal.
> Since c->trans_mod->request is pointing at p9_virtio_request, the location
> returning that error would be
(...snipped...)
> 281                         err = wait_event_interruptible(*chan->vc_wq,
> 282                                                         chan->ring_bufs_avail);
> 
>    here.

Oops. Not p9_virtio_request().

It is p9_client_rpc(). I misread the output lines.

> > > +	printk("%u:req->status = %u\n", current->pid, req->status);
> > >  	err = wait_event_interruptible(*req->wq,
> > >  				       req->status >= REQ_STATUS_RCVD);
> > > +	printk("%u:wait = %d\n", current->pid, err);

But anyway, I think this is interupt related bug.
