From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 03/27] Documentation/networking/igb.txt: update
 documentation
Date: Fri, 10 Dec 2010 15:50:24 +0000
Message-ID: <1291996224.11673.2.camel@bwh-desktop>
References: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1291974667-30254-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davem@davemleft.org, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18712 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637Ab0LJPu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 10:50:27 -0500
In-Reply-To: <1291974667-30254-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-10 at 01:50 -0800, Jeff Kirsher wrote:
> Update Intel Wired LAN igb documentation.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  Documentation/networking/igb.txt |   22 +++++++++++++++++++---
>  1 files changed, 19 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/networking/igb.txt b/Documentation/networking/igb.txt
> index ab2d718..393bdb7 100644
> --- a/Documentation/networking/igb.txt
> +++ b/Documentation/networking/igb.txt
> @@ -36,6 +36,7 @@ Default Value: 0
>  This parameter adds support for SR-IOV.  It causes the driver to spawn up to
>  max_vfs worth of virtual function.
>  
> +
>  Additional Configurations
>  =========================
>  
> @@ -60,7 +61,8 @@ Additional Configurations
>    Ethtool
>    -------
>    The driver utilizes the ethtool interface for driver configuration and
> -  diagnostics, as well as displaying statistical information.
> +  diagnostics, as well as displaying statistical information. The latest
> +  version of Ethtool can be found at:
>  
>    http://sourceforge.net/projects/gkernel.

Please update this to:
http://ftp.kernel.org/pub/software/network/ethtool/

> @@ -103,8 +105,8 @@ Additional Configurations
>  
>    NOTE: You need to have inet_lro enabled via either the CONFIG_INET_LRO or
>    CONFIG_INET_LRO_MODULE kernel config option. Additionally, if
> -  CONFIG_INET_LRO_MODULE is used, the inet_lro module needs to be loaded
> -  before the igb driver.
> +  CONFIG_INET_LRO_MODULE is used, the inet_lro module needs to be loaded before
> +  the igb driver.

This should be removed as you don't use inet_lro any more.

>    You can verify that the driver is using LRO by looking at these counters in
>    Ethtool:
> @@ -116,6 +118,20 @@ Additional Configurations
>  
>    NOTE: IPv6 and UDP are not supported by LRO.
>  
> +  MAC and VLAN anti-spoofing feature
> +  ----------------------------------
> +  When a malicious driver attempts to send a spoofed packet, it is dropped by
> +  the hardware and not transmitted.  An interrupt is sent to the PF driver
> +  notifying it of the spoof attempt.
> +
> +  When a spoofed packet is detected the PF driver will send the following
> +  message to the system log (displayed by  the "dmesg" command):
> +
> +  Spoof event(s) detected on VF(n)
> +
> +  Where n=the VF that attempted to do the spoofing.

I can't see that message in the PF driver code; does this actually apply
to the in-tree driver?  Also I hope this is rate-limited.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

