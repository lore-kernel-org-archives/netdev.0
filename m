From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 08/14] pktgen: reorganize transmit loop
Date: Thu, 27 Aug 2009 22:49:02 -0700
Message-ID: <20090827224902.49f80920@nehalam>
References: <20090827235506.624381734@vyatta.com>
 <20090827235705.740919364@vyatta.com>
 <4A975480.3080507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56947 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751621AbZH1FtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2009 01:49:07 -0400
In-Reply-To: <4A975480.3080507@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Aug 2009 20:52:32 -0700
Ben Greear <greearb@candelatech.com> wrote:

> +		default: /* Drivers are not supposed to return other
> values! */
> +			if (net_ratelimit())
> +				pr_info("pktgen: %s xmit error:
> %d\n",
> +					odev->name, ret);
>  			pkt_dev->errors++;
> 
> I believe this is faulty.  Things like vlans can send pkts to qdiscs
> of the underlying device and those can return other values.
> 
> Patric McHardy put in some patches recently to achieve this in a more
> uniform manner:
> 
> http://patchwork.ozlabs.org/patch/28340/
> 
> Thanks,
> Ben
> 

Since pktgen has its own way of generating vlan tags, it
makes no sense to use it on top of 8021q vlan driver.


-- 
