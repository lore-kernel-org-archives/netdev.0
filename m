From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 7/7] xen-netback: don't disconnect frontend when seeing
 oversize packet
Date: Tue, 9 Apr 2013 12:54:19 +0100
Message-ID: <20130409115419.GE16998@zion.uk.xensource.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
 <1365505655-8021-8-git-send-email-wei.liu2@citrix.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B71C5@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:27343 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935014Ab3DILyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 07:54:25 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B71C5@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 12:34:42PM +0100, David Laight wrote:
> > +		if (!drop_err && txp->size > first->size) {
> > +			if (net_ratelimit())
> > +				netdev_dbg(vif->dev,
> > +					   "Packet is bigger than frame.\n");
> 
> It must be worth printing txp->size and first->size here.
> Similarly for the other errors in the other patches.
> 

Sure.

> Probably difficult for some of these errors, but it is
> sometimes worth saving the last 'bad' item. So that with
> an appropriate tool (maybe hexdump of /dev/kmem) it is
> possible to look at the actual contents and thus determine
> the actual source of the error.
> 

I doubt that you can get much information by analysing txp, it is just
controll structure in ring, not the actual packet content. The packet is
still in DomU.


Wei.

> 	David
> 
