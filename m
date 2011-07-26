From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 2/2] be2net: use stats-sync to read/write
 64-bit stats
Date: Tue, 26 Jul 2011 07:58:26 -0700
Message-ID: <20110726075826.26bca7a9@s6510.ftrdhcpuser.net>
References: <1311657015-23465-1-git-send-email-sathya.perla@emulex.com>
	<1311657015-23465-3-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35553 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506Ab1GZO6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 10:58:20 -0400
In-Reply-To: <1311657015-23465-3-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jul 2011 10:40:15 +0530
Sathya Perla <sathya.perla@emulex.com> wrote:

> 64-bit stats in be2net are written/read as follows using the stats-sync
> interface for safe access in 32-bit archs:
> 
> 64-bit 		sync			writer			reader
> stats
> ------------------------------------------------------------------------------
> tx_stats	tx_stats->sync		be_xmit			be_get_stats64,
> 								ethtool
> tx-compl	tx_stats->sync_compl	tx-compl-processing	ethtool
> rx-stats	rx_stats->sync		rx-compl-processing	be_get_stats64,
> 								ethtool,
> 								eqd-update
> 
> This patch is based on Stephen Hemminger's earlier patch on the same issue...
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Is the tx complete stat even worth the effort? does it provide a useful metric?
Since rx/tx bytes are already in regular stats, keeping them in ethtool stats
is redundant.

These are just minor nits, you can ignore this advice if you want.
