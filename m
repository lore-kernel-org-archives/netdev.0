From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net V2] xen-netback: use jiffies_64 value to calculate
 credit timeout
Date: Mon, 28 Oct 2013 12:01:35 +0000
Message-ID: <20131028120135.GD23262@zion.uk.xensource.com>
References: <1382960117-13053-1-git-send-email-wei.liu2@citrix.com>
 <526E5D7302000078000FD41A@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	xen-devel <xen-devel@lists.xenproject.org>,
	<annie.li@oracle.com>, Jason Luan <jianhai.luan@oracle.com>,
	<netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:29212 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756243Ab3J1MBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 08:01:37 -0400
Content-Disposition: inline
In-Reply-To: <526E5D7302000078000FD41A@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 28, 2013 at 11:49:55AM +0000, Jan Beulich wrote:
> >>> On 28.10.13 at 12:35, Wei Liu <wei.liu2@citrix.com> wrote:
> 
> Two formal things:
> 
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -1185,18 +1185,17 @@ out:
> >  
> >  static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
> >  {
> > -	unsigned long now = jiffies;
> > -	unsigned long next_credit =
> > -		vif->credit_timeout.expires +
> > -		msecs_to_jiffies(vif->credit_usec / 1000);
> > +	u64 now = get_jiffies_64();
> > +	u64 next_credit = vif->credit_window_start +
> > +		(u64)msecs_to_jiffies(vif->credit_usec / 1000);
> 
> The cast to u64 seems pointless here.
> 
> > @@ -1207,7 +1206,8 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
> >  		vif->credit_timeout.function =
> >  			tx_credit_callback;
> >  		mod_timer(&vif->credit_timeout,
> > -			  next_credit);
> > +			  (unsigned long)next_credit);
> 
> And the cast here seems pointless too (gcc doesn't warn about
> truncations).
> 

Will fix these, thanks.

Wei.

> Jan
