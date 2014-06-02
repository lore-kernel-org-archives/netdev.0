From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH 2/3] cnic: Don't take cnic_dev_lock in
 cnic_alloc_uio_rings()
Date: Mon, 2 Jun 2014 13:31:54 -0700
Message-ID: <1401741114.6344.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1401491923-5480-1-git-send-email-mchan@broadcom.com>
	 <1401491923-5480-2-git-send-email-mchan@broadcom.com>
	 <1401491923-5480-3-git-send-email-mchan@broadcom.com>
	 <20140530223320.GA23581@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<nhorman@tuxdriver.com>
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:5938 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642AbaFBUbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 16:31:55 -0400
In-Reply-To: <20140530223320.GA23581@f1.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 15:33 -0700, Benjamin Poirier wrote: 
> On 2014/05/30 16:18, Michael Chan wrote:
> > We are allocating memory with GFP_KERNEL under spinlock.  Since this is
> > the only call manipulating the cnic_udev_list and it is always under
> > rtnl_lock, cnic_dev_lock can be safely removed.
> 
> In that case, the many other instances of cnic_dev_lock throughout cnic
> should also be removed, no? 

I don't think so.  cnic_dev_list still needs to be protected using
cnic_dev_lock.  cnic_register_driver() for example is not called with
rtnl_lock().
