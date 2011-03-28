From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] net: fix ethtool->set_flags not intended -EINVAL return
 value
Date: Mon, 28 Mar 2011 16:48:37 +0200
Message-ID: <20110328144837.GB4037@redhat.com>
References: <20110323095415.GA7098@redhat.com>
 <20110328142155.GA26423@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37507 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753539Ab1C1OtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2011 10:49:08 -0400
Content-Disposition: inline
In-Reply-To: <20110328142155.GA26423@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2011 at 09:21:57AM -0500, Jon Mason wrote:
> > -	if (data & ~ETH_FLAG_RXHASH)
> > -		return -EOPNOTSUPP;
> > +	if (ethtool_invalid_flags(dev, data, ETH_FLAG_RXHASH))
> > +		return -EINVAL;
> 
> The return code value is being changed, which is not relevant to this
> patch.  Perhaps a secondary patch should be created to make all driver
> set_flags calls return EOPNOTSUPP for unsupported flag setting.

Linux network developers agree some time ago that EINVAL should be used
in this case.

Stanislaw
