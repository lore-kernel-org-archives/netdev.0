From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH 2/3] cnic: Don't take cnic_dev_lock in
 cnic_alloc_uio_rings()
Date: Sat, 31 May 2014 17:07:55 -0700
Message-ID: <1401581275.9728.179.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1401491923-5480-1-git-send-email-mchan@broadcom.com>
	 <1401491923-5480-2-git-send-email-mchan@broadcom.com>
	 <1401491923-5480-3-git-send-email-mchan@broadcom.com>
	 <20140531130700.GB27590@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:21617 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbaFAAH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 20:07:56 -0400
In-Reply-To: <20140531130700.GB27590@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-05-31 at 09:07 -0400, Neil Horman wrote: 
> On Fri, May 30, 2014 at 04:18:42PM -0700, Michael Chan wrote:
> > We are allocating memory with GFP_KERNEL under spinlock.  Since this is
> > the only call manipulating the cnic_udev_list and it is always under
> > rtnl_lock, cnic_dev_lock can be safely removed.
> > 
>  I don't think this is accurate.  cnic_alloc_uio_rings seems to protect the list
> with cnic_dev_lock, but has several paths (those calling ->alloc_resc()), that
> never hold the rtnl_lock.
> 
> 
->alloc_resc() is called by cnic_start_hw().  cnic_start_hw() is called
from 2 paths.  One is from netdev events which always hold rtnl_lock.
The other path is from bnx2/bnx2x with CNIC_CTL_START_CMD.  In bnx2,
this is called during bnx2_netif_start() which is always under
rtnl_lock.  In bnx2x, it is called during bnx2x_nic_load() which is also
under rtnl_lock().  Thanks.
