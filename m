From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] xen-netback: Changes around carrier
 handling
Date: Tue, 05 Aug 2014 16:07:48 -0700 (PDT)
Message-ID: <20140805.160748.1185917042908283028.davem@davemloft.net>
References: <1407165658-20146-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	david.vrabel@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407165658-20146-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Mon, 4 Aug 2014 16:20:56 +0100

> This series starts using carrier off as a way to purge packets when the guest is
> not able (or willing) to receive them. It is a much faster way to get rid of
> packets waiting for an overwhelmed guest.
> The first patch changes current netback code where it relies currently on
> netif_carrier_ok.
> The second turns off the carrier if the guest times out on a queue, and only
> turn it on again if that queue (or queues) resurrects.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied, but I have some reservations:

1) This is starting to bleed what is normally qdisc type policy into the
   driver.

2) There are other drivers that could run into this kind of situation and
   have similar concerns, therefore we should make sure we have a consistent
   approach that such entities use to handle this problem.

Part of the problem is that netif_carrier_off() only partially mimicks
the situation.  It expresses the "transmitter is down so packets
aren't going onto the wire" part, which keeps the watchdog from
spitting out log messages ever time it fires.  But it doesn't deal
with packet freeing policy meanwhile, which I guess is the part that
this patch series is largely trying to address.

Thanks.
