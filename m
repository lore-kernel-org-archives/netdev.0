From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH] NFC: fix device-allocation error return
Date: Sat, 22 Jul 2017 15:32:28 +0200
Message-ID: <20170722133228.GE2729@localhost>
References: <20170709110858.20331-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Johan Hovold <johan@kernel.org>,
        stable <stable@vger.kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Samuel Ortiz <sameo@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:35375 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750830AbdGVNcf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 09:32:35 -0400
Content-Disposition: inline
In-Reply-To: <20170709110858.20331-1-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 09, 2017 at 01:08:58PM +0200, Johan Hovold wrote:
> A recent change fixing NFC device allocation itself introduced an
> error-handling bug by returning an error pointer in case device-id
> allocation failed. This is clearly broken as the callers still expected
> NULL to be returned on errors as detected by Dan's static checker.
> 
> Fix this up by returning NULL in the event that we've run out of memory
> when allocating a new device id.
> 
> Note that the offending commit is marked for stable (3.8) so this fix
> needs to be backported along with it.
> 
> Fixes: 20777bc57c34 ("NFC: fix broken device allocation")
> Cc: stable <stable@vger.kernel.org>	# 3.8
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Johan Hovold <johan@kernel.org>

Samuel or David,

Could you apply this follow-up fix so that it can be backported along
with the offending commit (which was just added to the stable queues)?

We would only hit this error path if an ida allocation fails due to OOM;
so while this is not critical, it would still be nice to get it fixed.

Thanks,
Johan
