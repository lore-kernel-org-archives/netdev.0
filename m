From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH net v4 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Fri, 29 Aug 2014 10:20:45 -0700
Message-ID: <20140829172045.GA1245@f1.synalogic.ca>
References: <1409187858-7698-1-git-send-email-bpoirier@suse.de>
 <1409187858-7698-4-git-send-email-bpoirier@suse.de>
 <1409282668.12635.21.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1409282668.12635.21.camel@prashant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/08/28 20:24, Prashant Sreedharan wrote:
> >  
> > -	for (i = 0; i < tp->irq_max; i++)
> > -		tp->napi[i].tx_pending = ering->tx_pending;
> > +	dev->gso_max_segs = TG3_TX_SEG_PER_DESC(ering->tx_pending - 1);
> > +	for (i = 0; i < tp->irq_max; i++) {
> > +		struct tg3_napi *tnapi = &tp->napi[i];
> > +
> > +		tnapi->tx_pending = ering->tx_pending;
> > +		if (netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)) &&
> 
> Need to limit the number of TX queues to tp->txq_cnt instead of
> tp->irq_max as txq_cnt can be less than irq_max.
> 
> netif_set_real_num_tx_queues(tp->dev, tp->txq_cnt);

Thanks for your careful review, I'll resubmit shortly.

> 
> > +		    tnapi->wakeup_thresh >= ering->tx_pending)
> > +			tnapi->wakeup_thresh = MAX_SKB_FRAGS + 1;
> > +	}
> >  
> 
> 
> 
