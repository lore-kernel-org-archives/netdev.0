From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] drivers/atm/firestream.c: suppress uninitialized
 var warning
Date: Fri, 28 Mar 2008 16:58:12 -0700 (PDT)
Message-ID: <20080328.165812.253071507.davem@davemloft.net>
References: <200803282137.m2SLbTJl011626@imap1.linux-foundation.org>
	<20080328.162017.169462194.davem@davemloft.net>
	<20080328165437.bfd7726c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil, jeff@garzik.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54487
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756712AbYC1X6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:58:12 -0400
In-Reply-To: <20080328165437.bfd7726c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 28 Mar 2008 16:54:37 -0700

> > diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
> > index 47c57a4..98099f5 100644
> > --- a/drivers/atm/firestream.c
> > +++ b/drivers/atm/firestream.c
> > @@ -978,6 +978,7 @@ static int fs_open(struct atm_vcc *atm_vcc)
> >  		/* Docs are vague about this atm_hdr field. By the way, the FS
> >  		 * chip makes odd errors if lower bits are set.... -- REW */
> >  		tc->atm_hdr =  (vpi << 20) | (vci << 4); 
> > +		tmc0 = 0;
> >  		{
> >  			int pcr = atm_pcr_goal (txtp);
> 
> Whereas the reader doesn't know why that unneeded initialisation is there.

git show $(git blame drivers/atm/firestream.c | grep "tmc0 = 0" | \
	   awk ' { print $1 } ')
