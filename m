From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Wed, 18 May 2016 11:21:59 +0300
Message-ID: <20160518112045-mutt-send-email-mst@redhat.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
 <20160516070012-mutt-send-email-mst@redhat.com>
 <57397C2B.7000603@redhat.com>
 <20160516105434-mutt-send-email-mst@redhat.com>
 <573A761D.8080909@redhat.com>
 <20160518101631.368e3447@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160518101631.368e3447@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2016 at 10:16:31AM +0200, Jesper Dangaard Brouer wrote:
> 
> On Tue, 17 May 2016 09:38:37 +0800 Jason Wang <jasowang@redhat.com> wrote:
> 
> > >> And if tx_queue_length is not power of 2,
> > >> we probably need modulus to calculate the capacity.  
> > > Is that really that important for speed?  
> > 
> > Not sure, I can test.
> 
> In my experience, yes, adding a modulus does affect performance.

How about simple
	if (unlikely(++idx > size))
		idx = 0;


> > 
> > Right, this sounds a good solution.
> 
> Good idea.

I'm not that sure - it's clearly wasting memory.

> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
