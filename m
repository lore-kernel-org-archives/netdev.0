From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] bnx2: Increase max rx ring size from 1K to
 2K
Date: Tue, 19 Oct 2010 10:03:30 -0700
Message-ID: <1287507810.11904.23.camel@HP1>
References: <1287448254-14173-1-git-send-email-mchan@broadcom.com>
 <20101019.011434.226774173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "andy@greyhouse.net" <andy@greyhouse.net>,
	"jfeeney@redhat.com" <jfeeney@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2872 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755997Ab0JSRGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 13:06:20 -0400
In-Reply-To: <20101019.011434.226774173.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2010-10-19 at 01:14 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Mon, 18 Oct 2010 17:30:54 -0700
> 
> > A number of customers are reporting packet loss under certain workloads
> > (e.g. heavy bursts of small packets) with flow control disabled.  A larger
> > rx ring helps to prevent these losses.
> > 
> > No change in default rx ring size and memory consumption.
> > 
> > Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> > Acked-by: John Feeney <jfeeney@redhat.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> I don't see how it's any better to queue things more deeply in
> hardware, compared to simply using hardware flow control since that's
> what it's for and makes the queuing happen in the networking stack of
> the sender, in software, which in the end performs better and gives
> better feedback to the source of the data.

There are situations where flow control is not desirable.  For example,
if there are many multicast receivers in the network, you may not want a
few slow receivers to slow down the entire network with flow control.

> 
> These huge RX queue sizes are absolutely rediculious, and I've
> complained about this before.

Yes you have and I was initially hesitant to post this patch.  But the
customer sees that many other 1G drivers in the tree can have bigger
ring sizes and as a result, they have fewer packet drops using these
other devices.  In fact, 2K is still much smaller than many other 1G
drivers in the tree.  Please also note that this does not add any extra
memory to the default configuration.  Thanks.

> 
> And instead of seeing less of this, I keep seeing more of this stuff.
> Please exert some pushback on these folks who are doing such insane
> things.
> 
> Thanks.
> 


