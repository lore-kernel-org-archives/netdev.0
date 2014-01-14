From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 1/2] net/mlx4_core: clean up cq_res_start_move_to()
Date: Tue, 14 Jan 2014 12:23:50 +0100
Message-ID: <1389698630.20290.48.camel@x220>
References: <1389099678.15032.19.camel@x41>
	 <20140114084752.1db64b21@jpm-OptiPlex-GX620>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpb-ews07.kpnxchange.com ([213.75.39.10]:52257 "EHLO
	cpsmtpb-ews07.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751342AbaANLXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 06:23:53 -0500
In-Reply-To: <20140114084752.1db64b21@jpm-OptiPlex-GX620>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 08:47 +0200, Jack Morgenstein wrote:
> On Tue, 07 Jan 2014 14:01:18 +0100
> Paul Bolle <pebolle@tiscali.nl> wrote:
> 
> > +	} else {
> > +		/* state == RES_CQ_HW */
> > +		if (r->com.state != RES_CQ_ALLOCATED)
> 
> if (state != RES_CQ_HW || r->com.state != RES_CQ_ALLOCATED)
> to protect against any bad calls to this function
> (although I know that currently there are none).

So we end up with
         } else if (state != RES_CQ_HW || r->com.state != RES_CQ_ALLOCATED) {
                 err = -EINVAL;
         } else {
                 err = 0;
         }

don't we? Which is fine with me, as GCC still is then able to correctly
analyze this function.

> This also preserves the behavior of the switch statement.
> 
> >  			err = -EINVAL;
> > -		}
> > +		else
> > +			err = 0;
> > +	}
> >  
> > -		if (!err) {
> > -			r->com.from_state = r->com.state;
> > -			r->com.to_state = state;
> > -			r->com.state = RES_CQ_BUSY;
> > -			if (cq)
> > -				*cq = r;
> > -		}
> > +	if (!err) {
> > +		r->com.from_state = r->com.state;
> > +		r->com.to_state = state;
> > +		r->com.state = RES_CQ_BUSY;
> 
> Please keep the "if" here.  Protects against (future) bad calls.
> 
> > +		*cq = r;
> >  	}

There seems to be a school of thought that says it's better to trigger
an Oops if a programming error is made (in this case by passing a NULL
cq) then silently handle that (future) programming error and make
debugging harder. But, even it that school of thought really exists,
this is up to you. Besides, it's only a triviality I added to my
patches.

Thanks for the review! I hope to send in a v2 of my patches shortly.


Paul Bolle
