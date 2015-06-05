From: Joe Perches <joe@perches.com>
Subject: Re: [Xen-devel] [PATCH v2 1/2] net/xen-netfront: Correct printf
 format in xennet_get_responses
Date: Fri, 05 Jun 2015 08:49:00 -0700
Message-ID: <1433519340.2658.51.camel@perches.com>
References: <1433350510-12846-1-git-send-email-julien.grall@citrix.com>
	 <1433350510-12846-2-git-send-email-julien.grall@citrix.com>
	 <1433351196.4861.131.camel@perches.com> <5570484C.8040201@citrix.com>
	 <557048B1.9070805@citrix.com> <55704A02.9010001@citrix.com>
	 <1433435132.4861.184.camel@perches.com> <55719752.2070909@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>, ian.campbell@citrix.com,
	netdev@vger.kernel.org, stefano.stabellini@eu.citrix.com,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55719752.2070909@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-06-05 at 13:34 +0100, Julien Grall wrote:
> On 04/06/15 17:25, Joe Perches wrote:
> > On Thu, 2015-06-04 at 13:52 +0100, Julien Grall wrote:
> >> On 04/06/15 13:46, David Vrabel wrote:
> >>> On 04/06/15 13:45, Julien Grall wrote:
> >>>> On 03/06/15 18:06, Joe Perches wrote:
> >>>>> On Wed, 2015-06-03 at 17:55 +0100, Julien Grall wrote:
> >>>>>> rx->status is an int16_t, print it using %d rather than %u in order to
> >>>>>> have a meaningful value when the field is negative.
> >>>>> []
> >>>>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> >>>>> []
> >>>>>> @@ -733,7 +733,7 @@ static int xennet_get_responses(struct netfront_queue *queue,
> >>>>>>  		if (unlikely(rx->status < 0 ||
> >>>>>>  			     rx->offset + rx->status > PAGE_SIZE)) {
> >>>>>>  			if (net_ratelimit())
> >>>>>> -				dev_warn(dev, "rx->offset: %x, size: %u\n",
> >>>>>> +				dev_warn(dev, "rx->offset: %x, size: %d\n",
> >>>>>
> >>>>> If you're going to do this, perhaps it'd be sensible to
> >>>>> also change the %x to %#x or 0x%x so that people don't
> >>>>> mistake offset without an [a-f] for decimal.
> >>>>
> >>>> Good idea. I will resend a version of this series.
> >>>>
> >>>> David, can I keep you Reviewed-by for this change?#
> >>>
> >>> Can you make the offset %d instead?
> > 
> > If you do, please change similar uses in
> > drivers/net/xen-netback/ in the same patch.
> 
> The format is not really consistent accross the 2 drivers and even
> within the same driver (see pending_idx which is some times print with
> %x and %d).
> 
> Anyway, ss it's a different drivers and maintainers I will prefer to
> send a separate patch for this.

It's all xen to me, but thanks.
