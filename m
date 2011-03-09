From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] net: Allow no-cache copy from user on transmit
Date: Tue, 8 Mar 2011 22:12:52 -0800
Message-ID: <20110308221252.34385919@s6510>
References: <alpine.DEB.2.00.1103082053350.1433@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37331 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169Ab1CIGM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 01:12:56 -0500
In-Reply-To: <alpine.DEB.2.00.1103082053350.1433@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Mar 2011 21:05:06 -0800 (PST)
Tom Herbert <therbert@google.com> wrote:

> This patch uses __copy_from_user_nocache (from skb_copy_to_page)
> on transmit to bypass data cache for a performance improvement.
> This functionality is configurable per device using ethtool, the
> device must also be doing TX csum offload to enable.  It seems
> reasonable to set this when the device does not copy or
> otherwise touch the data.
> 
> This patch was tested using 200 instances of netperf TCP_RR with
> 1400 byte request and one byte reply.  Platform is 16 core AMD.
> 
> No-cache copy disabled:
>    672703 tps, 97.13% client utilization
>    50/90/99% latency 244.31 484.205 1028.41
> 
> No-cache copy enabled:
>    702113 tps, 96.16% client utilization,
>    50/90/99% latency 238.56 467.56 956.955
> 
> This seems to provide a nice little performance improvement and is
> consistent in the tests I ran.  Presumably, this would provide
> the greatest  benfits in the presence of an application workload
> stressing the cache and a lot of transmit data happening.  I don't
> yet see a downside to using this.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Since this is not an ethernet only optimization or device
specific, I would prefer it be a property of device not
something in ethtool.

