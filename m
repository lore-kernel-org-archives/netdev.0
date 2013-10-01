From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 2/2] Hide state of VLAN tag offload and LRO if
 the kernel is too old
Date: Tue, 1 Oct 2013 16:36:15 +0100
Message-ID: <1380641775.1939.1.camel@bwh-desktop.uk.level5networks.com>
References: <1379978791.2485.87.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62680 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917Ab3JAPgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 11:36:18 -0400
In-Reply-To: <1379978791.2485.87.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 00:26 +0100, Ben Hutchings wrote:
> Starting with Linux 2.6.37 and ethtool 2.6.36 it was possible to show
> the state of VLAN tag offload (using ETHTOOL_GFLAGS).  But the state
> would always be shown as 'off' for older kernel versions, even though
> VLAN tag offload had been implemented long before this.
> 
> In ethtool 3.4.2 I attempted to fix this by also reading the state of
> VLAN tag offload from the 'features' attribute in sysfs.  But this had
> to be reverted because it causes 'ethtool -K' to pass the flags back
> into ETHTOOL_SFLAGS.
> 
> Instead, hide the VLAN tag offload flags if the kernel is older than
> 2.6.37.
> 
> Similarly, LRO was implemented some time before it was exposed through
> ETHTOOL_GFLAGS in Linux 2.6.24.  So hide the LRO flag if the kernel
> is older than that.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  ethtool.c | 58 ++++++++++++++++++++++++++++++++++++++++++++++------------
>  1 file changed, 46 insertions(+), 12 deletions(-)

I've now applied this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
