From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH] xen-netback: making the bandwidth limiter runtime
 settable
Date: Wed, 18 Mar 2015 16:28:07 +0000
Message-ID: <20150318162807.GA6334@zion.uk.xensource.com>
References: <1426251065-24279-1-git-send-email-imrep.amz@gmail.com>
 <20150317111749.GC27314@zion.uk.xensource.com> <5509A5F4.2010402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, "Palik, Imre" <imrep@amazon.de>,
	"Anthony Liguori" <aliguori@amazon.com>
To: Imre Palik <imrep.amz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5509A5F4.2010402@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 18, 2015 at 05:21:08PM +0100, Imre Palik wrote:
> On 03/17/15 12:17, Wei Liu wrote:
> > On Fri, Mar 13, 2015 at 01:51:05PM +0100, Imre Palik wrote:
> >> From: "Palik, Imre" <imrep@amazon.de>
> >>
> >> With the current netback, the bandwidth limiter's parameters are only
> >> settable during vif setup time.  This patch register a watch on them, and
> >> thus makes them runtime changeable.
> >>
> >> When the watch fires, the timer is reset.  The timer's mutex is used for
> >> fencing the change.
> >>
> > 
> > I think this is a valid idea.  Just that this commit message is not
> > complete. It doesn't describe everything this patch does.
> > 
> >> Cc: Anthony Liguori <aliguori@amazon.com>
> >> Signed-off-by: Imre Palik <imrep@amazon.de>
> >> ---
> > [...]
> >>  	queue->rx_queue_max = XENVIF_RX_QUEUE_BYTES;
> >> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> >> index cab9f52..bcc1880 100644
> >> --- a/drivers/net/xen-netback/netback.c
> >> +++ b/drivers/net/xen-netback/netback.c
> >> @@ -641,7 +641,7 @@ static void tx_add_credit(struct xenvif_queue *queue)
> >>  	queue->remaining_credit = min(max_credit, max_burst);
> >>  }
> >>  
> >> -static void tx_credit_callback(unsigned long data)
> >> +void xenvif_tx_credit_callback(unsigned long data)
> > 
> > Please keep this function static.
> 
> The trouble with that, is that now I am initialising credit_timeout.function in
> drivers/net/xen-netback/interface.c .
> 

Oh, yes. I misread the hunk of common.h. Sorry about the noise.

Wei.
