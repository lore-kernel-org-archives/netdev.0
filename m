From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/2] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods (v3)
Date: Fri, 29 Jul 2011 09:16:42 +0300
Message-ID: <20110729061642.GA9884@redhat.com>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>, mashirle@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47292 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753847Ab1G2GQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 02:16:39 -0400
Content-Disposition: inline
In-Reply-To: <1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 26, 2011 at 12:05:36PM -0400, Neil Horman wrote:
> Ok, after considering all your comments, Dave suggested this as an alternate
> approach:
> 
> 1) We create a new priv_flag, IFF_SKB_TX_SHARED, to identify drivers capable of
> handling shared skbs.  Default is to not set this flag
> 
> 2) Modify ether_setup to enable this flag, under the assumption that any driver
> calling this  function is initalizing a real ethernet device and as such can
> handle shared skbs since they don't tend to store state in the skb struct.
> Pktgen can then query this flag when a user script attempts to issue the
> clone_skb command and decide if it is to be alowed or not.
> 
> 3) Audit the network drivers calling ether_setup to identify any code doing so
> that can't actualy handle shared skbs and manually disable the new flag.  There
> are about 10 drivers in this category.
> 
> Change notes:
> v3) Fixed Erics note in which I tested the length of the passed in string rather
> than its converted value for beign > 0
> 
> Thoughts/reviews aprpeciated.
> Neil

It might be a good idea to disable vhost-net zerocopy for
such devices as well: these skbs are shared with userspace.
Shirley, what do you think?

-- 
MST
