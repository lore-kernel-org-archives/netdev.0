From: David Vrabel <dvrabel@cantab.net>
Subject: Re: [Xen-devel] [PATCH net V2] xen-netback: use jiffies_64 value
 to calculate credit timeout
Date: Mon, 28 Oct 2013 11:53:38 +0000
Message-ID: <526E5042.7080406@cantab.net>
References: <1382960117-13053-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>, annie.li@oracle.com,
	david.vrabel@citrix.com, jbeulich@suse.com,
	Jason Luan <jianhai.luan@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01c.mail.zen.net.uk ([212.23.1.5]:60357 "EHLO
	smarthost01c.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755944Ab3J1Lxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 07:53:47 -0400
In-Reply-To: <1382960117-13053-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/10/2013 11:35, Wei Liu wrote:
> time_after_eq() only works if the delta is < MAX_ULONG/2.
> 
> For a 32bit Dom0, if netfront sends packets at a very low rate, the time
> between subsequent calls to tx_credit_exceeded() may exceed MAX_ULONG/2
> and the test for timer_after_eq() will be incorrect. Credit will not be
> replenished and the guest may become unable to send packets (e.g., if
> prior to the long gap, all credit was exhausted).
> 
> Use jiffies_64 variant to mitigate this problem for 32bit Dom0.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
