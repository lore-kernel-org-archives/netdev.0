From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] sysfs: remove error messages for -EEXIST case
Date: Thu, 15 May 2008 03:00:54 -0700 (PDT)
Message-ID: <20080515.030054.247673168.davem@davemloft.net>
References: <20080515095246.3b6a0d1d@gondolin.boeblingen.de.ibm.com>
	<20080515.010139.219194657.davem@davemloft.net>
	<20080515113131.2cea2bce@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, greg@kroah.com, fubar@us.ibm.com,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: cornelia.huck@de.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757347AbYEOKBP@vger.kernel.org>
In-Reply-To: <20080515113131.2cea2bce@gondolin.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cornelia Huck <cornelia.huck@de.ibm.com>
Date: Thu, 15 May 2008 11:31:31 +0200

> On Thu, 15 May 2008 01:01:39 -0700 (PDT),
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Cornelia Huck <cornelia.huck@de.ibm.com>
> > Date: Thu, 15 May 2008 09:52:46 +0200
> > 
> > > >  int sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
> > > >  {
> > > > -	if (sysfs_find_dirent(acxt->parent_sd, sd->s_name)) {
> > > > -		printk(KERN_WARNING "sysfs: duplicate filename '%s' "
> > > > -		       "can not be created\n", sd->s_name);
> > > > -		WARN_ON(1);
> > > > +	if (sysfs_find_dirent(acxt->parent_sd, sd->s_name))
> > > >  		return -EEXIST;
> > > > -	}
> > > > 
> > > >  	sd->s_parent = sysfs_get(acxt->parent_sd);
> > > 
> > > ...but this will cause many useful warnings to disappear.
> > > 
> > > What to do here?
> > 
> > Make a __sysfs_add_one() that doesn't warn.   Make
> > sysfs_add_one() be a wrapper around __sysfs_add_one()
> > that warns.
> > 
> > Change networking to call __sysfs_add_one().
> 
> Like this (not even compile tested)?

No, the idea is that the __sysfs_add_one() wouldn't need a parameter
at all.  sysfs_add_one() just needs to check for -EEXIST from
__sysfs_add_one() to decide whether to warn or not.
