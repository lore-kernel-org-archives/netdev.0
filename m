From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH] NFC: fix device-allocation error return
Date: Mon, 28 Aug 2017 10:39:12 +0200
Message-ID: <20170828083912.GB20634@localhost>
References: <20170709110858.20331-1-johan@kernel.org>
 <20170722133228.GE2729@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Johan Hovold <johan@kernel.org>,
        stable <stable@vger.kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Ben Hutchings <ben.hutchings@codethink.co.uk>
To: Samuel Ortiz <sameo@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170722133228.GE2729@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samuel or David,

On Sat, Jul 22, 2017 at 03:32:28PM +0200, Johan Hovold wrote:
> On Sun, Jul 09, 2017 at 01:08:58PM +0200, Johan Hovold wrote:
> > A recent change fixing NFC device allocation itself introduced an
> > error-handling bug by returning an error pointer in case device-id
> > allocation failed. This is clearly broken as the callers still expected
> > NULL to be returned on errors as detected by Dan's static checker.
> > 
> > Fix this up by returning NULL in the event that we've run out of memory
> > when allocating a new device id.
> > 
> > Note that the offending commit is marked for stable (3.8) so this fix
> > needs to be backported along with it.
> > 
> > Fixes: 20777bc57c34 ("NFC: fix broken device allocation")
> > Cc: stable <stable@vger.kernel.org>	# 3.8
> > Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> > Signed-off-by: Johan Hovold <johan@kernel.org>

> Could you apply this follow-up fix so that it can be backported along
> with the offending commit (which was just added to the stable queues)?
> 
> We would only hit this error path if an ida allocation fails due to OOM;
> so while this is not critical, it would still be nice to get it fixed.

Another reminder about this one; can you apply it so we can get it into
4.14-rc1?

Note that the offending commit has now been backported to the stable
trees and we really want this trivial follow-up fix to be backported as
well.

Let me know if you want me to resend the patch.

Thanks,
Johan
