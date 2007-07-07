From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 7/9] netconsole: Support multiple logging targets
Date: Sun, 8 Jul 2007 01:16:17 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707080108240.3789@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110814.28520.94417.sendpatchset@cselinux1.cse.iitk.ac.in>
 <468FDC8D.6080208@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: KII Keiichi <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:55224 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753326AbXGGTY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jul 2007 15:24:26 -0400
In-Reply-To: <468FDC8D.6080208@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sun, 8 Jul 2007, KII Keiichi wrote:
> Hi Satyam,
> 
> The following comments aren't essential.
> 
> >  	if (!(event == NETDEV_UP || event == NETDEV_DOWN ||
> >  	      event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
> > -	      	goto done;
> > +		goto done;
> 
> The above diff lines are extra.

Eek, looks like some whitespace correction leaked in here. I'll take care
not to produce the bad whitespace in the first place the first time this
line comes in.

> > +	spin_lock_irqsave(&target_list_lock, flags);
> > +	list_for_each_entry(nt, &target_list, list) {
> > +		if (nt->np.dev == dev) {
> > +			switch (event) {
> > +			case NETDEV_UP:
> > +			case NETDEV_DOWN:
> > +				nt->dev_status = net_dev_is_up(nt->np.dev);
> > +				break;
> > +
> > +			case NETDEV_CHANGEADDR:
> > +				memcpy(nt->np.local_mac, dev->dev_addr, ETH_ALEN);
> 
> The above line is over 80 characters.

Hmm, yes, but only by 2 columns. It's a simple and readable line
in its present form, so I'm not sure I'd want to be an extremist
and cut it into two ...

Satyam
