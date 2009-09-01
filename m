From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 08/14] pktgen: reorganize transmit loop
Date: Tue, 1 Sep 2009 14:30:33 -0700
Message-ID: <20090901143033.0e9cb7ec@nehalam>
References: <20090827235705.740919364@vyatta.com>
	<4A975480.3080507@candelatech.com>
	<20090827224902.49f80920@nehalam>
	<20090828.230428.211927371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, robert.olsson@its.uu.se,
	netdev@vger.kernel.org, tglx@linutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54740 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755180AbZIAVag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 17:30:36 -0400
In-Reply-To: <20090828.230428.211927371.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2009 23:04:28 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 27 Aug 2009 22:49:02 -0700
> 
> > On Thu, 27 Aug 2009 20:52:32 -0700
> > Ben Greear <greearb@candelatech.com> wrote:
> > 
> >> +		default: /* Drivers are not supposed to return other
> >> values! */
> >> +			if (net_ratelimit())
> >> +				pr_info("pktgen: %s xmit error:
> >> %d\n",
> >> +					odev->name, ret);
> >>  			pkt_dev->errors++;
> >> 
> >> I believe this is faulty.  Things like vlans can send pkts to qdiscs
> >> of the underlying device and those can return other values.
> >> 
> >> Patric McHardy put in some patches recently to achieve this in a more
> >> uniform manner:
> >> 
> >> http://patchwork.ozlabs.org/patch/28340/
> >> 
> >> Thanks,
> >> Ben
> >> 
> > 
> > Since pktgen has its own way of generating vlan tags, it
> > makes no sense to use it on top of 8021q vlan driver.
> 
> I think Patrick's goals are quite sound, and with his patch we
> could let pktgen transmit over vlan just like any other device.
> 
> Otherwise we give no way to use pktgen to test the VLAN transmit path.

The only valid returns from device are OK, BUSY, or LOCKED
anything else is an error and should never occur.

If the vlan code returns other values, it must translate.

-- 
