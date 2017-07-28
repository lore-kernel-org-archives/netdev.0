From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 3/3] tap: XDP support
Date: Fri, 28 Jul 2017 07:05:03 +0300
Message-ID: <20170728070329-mutt-send-email-mst@kernel.org>
References: <1501147533-12368-1-git-send-email-jasowang@redhat.com>
 <1501147533-12368-4-git-send-email-jasowang@redhat.com>
 <20170727201338.65d56b2a@cakuba.netronome.com>
 <7d1cb7bf-43c1-3993-be00-04e4676dd917@redhat.com>
 <20170728064603-mutt-send-email-mst@kernel.org>
 <a53d61f5-584c-db8a-be1f-ddec0666d7df@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jakub Kicinski <kubakici@wp.pl>, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a53d61f5-584c-db8a-be1f-ddec0666d7df@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 11:50:45AM +0800, Jason Wang wrote:
> 
> 
> On 2017年07月28日 11:46, Michael S. Tsirkin wrote:
> > On Fri, Jul 28, 2017 at 11:28:54AM +0800, Jason Wang wrote:
> > > > > +	old_prog = rtnl_dereference(tun->xdp_prog);
> > > > > +	if (old_prog)
> > > > > +		bpf_prog_put(old_prog);
> > > > > +	rcu_assign_pointer(tun->xdp_prog, prog);
> > > > Is this OK?  Could this lead to the program getting freed and then
> > > > datapath accessing a stale pointer?  I mean in the scenario where the
> > > > process gets pre-empted between the bpf_prog_put() and
> > > > rcu_assign_pointer()?
> > > Will call bpf_prog_put() after rcu_assign_pointer().
> > I suspect you need to sync RCU or something before that.
> 
> __bpf_prog_put() will do call_rcu(), so looks like it was ok.
> 
> Thanks

True - I missed that.

-- 
MST
