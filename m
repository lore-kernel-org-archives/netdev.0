From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/4] drivers/atm/firestream.c: suppress uninitialized
 var warning
Date: Fri, 28 Mar 2008 17:11:28 -0700
Message-ID: <20080328171128.ff03ec02.akpm@linux-foundation.org>
References: <200803282137.m2SLbTJl011626@imap1.linux-foundation.org>
	<20080328.162017.169462194.davem@davemloft.net>
	<20080328165437.bfd7726c.akpm@linux-foundation.org>
	<20080328.165812.253071507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil, jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41913 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753538AbYC2ALz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 20:11:55 -0400
In-Reply-To: <20080328.165812.253071507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Mar 2008 16:58:12 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Fri, 28 Mar 2008 16:54:37 -0700
> 
> > > diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
> > > index 47c57a4..98099f5 100644
> > > --- a/drivers/atm/firestream.c
> > > +++ b/drivers/atm/firestream.c
> > > @@ -978,6 +978,7 @@ static int fs_open(struct atm_vcc *atm_vcc)
> > >  		/* Docs are vague about this atm_hdr field. By the way, the FS
> > >  		 * chip makes odd errors if lower bits are set.... -- REW */
> > >  		tc->atm_hdr =  (vpi << 20) | (vci << 4); 
> > > +		tmc0 = 0;
> > >  		{
> > >  			int pcr = atm_pcr_goal (txtp);
> > 
> > Whereas the reader doesn't know why that unneeded initialisation is there.
> 
> git show $(git blame drivers/atm/firestream.c | grep "tmc0 = 0" | \
> 	   awk ' { print $1 } ')

Not practical.  By this argument we wouldn't need code comments at all.

Plus the bit from my earlier email which you snipped.

Plus uninitialized_var() gives us something to grep for and experiment with
if/when future gcc's get smarter.
