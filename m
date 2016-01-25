From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [RFC PATCH net] net/core: don't increment rx_dropped on inactive
 slaves
Date: Mon, 25 Jan 2016 09:27:20 -0500
Message-ID: <20160125142720.GD59058@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <20160124.224222.1748787418887617295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160124.224222.1748787418887617295.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 24, 2016 at 10:42:22PM -0800, David Miller wrote:
> From: Jarod Wilson <jarod@redhat.com>
> Date: Fri, 22 Jan 2016 14:11:22 -0500
> 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 8cba3d8..1354c7b 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -4153,8 +4153,11 @@ ncls:
> >  		else
> >  			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
> >  	} else {
> > +		if (deliver_exact)
> > +			goto inactive; /* bond or team inactive slave */
> >  drop:
> >  		atomic_long_inc(&skb->dev->rx_dropped);
> > +inactive:
> >  		kfree_skb(skb);
> >  		/* Jamal, now you will not able to escape explaining
> >  		 * me how you were going to use this. :-)
> > -- 
> > 1.8.3.1
> > 
> 
> I agree that rx_dropped is not the correct stat to bump here, but
> I'm totally against the event disappearing completely into thin
> air.
> 
> You have to replace the rx_dropped bump with _something_.
> 
> The only reason this hasn't been "fixed" yet is that everyone is
> too damn lazy to implement that "something".

Would you want to see all things that shouldn't increment rx_dropped come
in one shot, along with the four or so other counters, as discussed in the
prior thread, or can they be done piecemeal? To date, I'm really only
familiar with this particular case, and could probably get something
together this week. To address the rest, I'd have to poke around a bit
more and see what there is to see and do.

-- 
Jarod Wilson
jarod@redhat.com
