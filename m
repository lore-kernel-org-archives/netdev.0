From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: minor cleanups to bond + netpoll
Date: Tue, 19 Oct 2010 16:29:41 -0400
Message-ID: <20101019202941.GE7497@gospo.rdu.redhat.com>
References: <1287507866-25156-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, davem@davemloft.net, andy@greyhouse.net,
	amwang@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27625 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757180Ab0JSUaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 16:30:00 -0400
Content-Disposition: inline
In-Reply-To: <1287507866-25156-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 19, 2010 at 01:04:24PM -0400, nhorman@tuxdriver.com wrote:
> Testing that was onging when the the reset patchset to enable netpoll over
> bonding revealed some minor corner cases that are worth correcting.  In summary:
> 
> 1) Remove netpoll tx blocking from bond_release_all.  Its not needed and causes
> some uglyness when removing the bonding module, in the form of a backtrace that
> gets logged.  blocking isn't needed in this path anyway as the netconsole is
> already unregistered from us at this point
> 
> 2) Remove my changes to napi_poll.  Closer inspection of the bonding
> poll_controller show that we wind up recursively calling the napi poll routines
> for the slaves through sucsessive calls to netpoll_poll_dev.  My origional
> change is harmless, but its not really needed, so lets make the code simpler.
> 
> Further details available in the individual commit messages
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 

I've done some quick testing with these and they address the concerns I
raised with Neil about his first patch-set.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

