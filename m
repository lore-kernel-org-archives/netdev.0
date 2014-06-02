From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH 2/3] cnic: Don't take cnic_dev_lock in
 cnic_alloc_uio_rings()
Date: Mon, 2 Jun 2014 14:24:27 -0700
Message-ID: <20140602212427.GC17916@f1.synalogic.ca>
References: <1401491923-5480-1-git-send-email-mchan@broadcom.com>
 <1401491923-5480-2-git-send-email-mchan@broadcom.com>
 <1401491923-5480-3-git-send-email-mchan@broadcom.com>
 <20140530223320.GA23581@f1.synalogic.ca>
 <1401741114.6344.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, nhorman@tuxdriver.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:36763 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaFBVYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 17:24:30 -0400
Received: by mail-pb0-f45.google.com with SMTP id um1so4619452pbc.4
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 14:24:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1401741114.6344.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/06/02 13:31, Michael Chan wrote:
> On Fri, 2014-05-30 at 15:33 -0700, Benjamin Poirier wrote: 
> > On 2014/05/30 16:18, Michael Chan wrote:
> > > We are allocating memory with GFP_KERNEL under spinlock.  Since this is
> > > the only call manipulating the cnic_udev_list and it is always under
> > > rtnl_lock, cnic_dev_lock can be safely removed.
> > 
> > In that case, the many other instances of cnic_dev_lock throughout cnic
> > should also be removed, no? 
> 
> I don't think so.  cnic_dev_list still needs to be protected using
> cnic_dev_lock.  cnic_register_driver() for example is not called with
> rtnl_lock().
> 

Ah, that's right. I had not paid attention to the fact that the same
lock protected cnic_dev_list and cnic_udev_list. Thanks for pointing it
out.
