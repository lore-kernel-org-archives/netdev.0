From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] ether1: Use net_device_stats from struct net_device
Date: Wed, 18 Aug 2010 08:33:04 -0700
Message-ID: <20100818083304.2ef2eea4@nehalam>
References: <1282061719-19645-1-git-send-email-tklauser@distanz.ch>
	<1282115064-3701-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org, Dan Carpenter <error27@gmail.com>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57808 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745Ab0HRPdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 11:33:07 -0400
In-Reply-To: <1282115064-3701-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Aug 2010 09:04:24 +0200
Tobias Klauser <tklauser@distanz.ch> wrote:

>  
> -	memset (&priv(dev)->stats, 0, sizeof (struct net_device_stats));
> +	memset(&dev->stats, 0, sizeof(struct net_device_stats));

This is incorrect, just remove the memset.  The stats are initialized
when device is created.  The Linux device driver convention is to
keep stats when device is set down and brought back up; that is what
the majority of other drivers do.

-- 
