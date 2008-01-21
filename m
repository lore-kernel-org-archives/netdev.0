From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/4] dsmark: get rid of trivial function
Date: Mon, 21 Jan 2008 10:39:21 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801211029150.11803@kivilampi-30.cs.helsinki.fi>
References: <20080120130542.16720b45@deepthought> <20080120132550.056370c0@deepthought>
 <4793E460.5020804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56201 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167AbYAUIjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 03:39:23 -0500
In-Reply-To: <4793E460.5020804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Jan 2008, Patrick McHardy wrote:

> Stephen Hemminger wrote:
> > Replace loop in dsmark_valid_indices with equivalent bit math.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > --- a/net/sched/sch_dsmark.c	2008-01-20 13:07:58.000000000 -0800
> > +++ b/net/sched/sch_dsmark.c	2008-01-20 13:22:54.000000000 -0800
> > @@ -45,13 +45,8 @@ struct dsmark_qdisc_data {
> >  
> >  static inline int dsmark_valid_indices(u16 indices)
> >  {
> > -	while (indices != 1) {
> > -		if (indices & 1)
> > -			return 0;
> > -		indices >>= 1;
> > -	}
> > -
> > -	return 1;
> > +	/* Must have only one bit set */
> > +	return (indices & (indices - 1)) == 0;

Isn't there some magic under include/linux to do that btw, I suppose 
that if the caller side zero check is pushed down there too, the
is_power_of_2() is 100% match? :-) 

> hweight seems easier to understand, it took me a bit
> to realize that the comment matches the code :)

In addition, the original seems infinite loop with zero indices given
but luckily that was checked at the caller site already...


-- 
 i.
