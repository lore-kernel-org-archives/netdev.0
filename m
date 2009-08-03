From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 7/7] venet: add scatter-gather/GSO support
Date: Mon, 3 Aug 2009 11:33:55 -0700
Message-ID: <20090803113355.734e69b6@nehalam>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
	<20090803171807.17268.49836.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46323 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090AbZHCSeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2009 14:34:00 -0400
In-Reply-To: <20090803171807.17268.49836.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Aug 2009 13:18:07 -0400
Gregory Haskins <ghaskins@novell.com> wrote:

> +	struct {
> +		int                sg:1;
> +		int                tso:1;
> +		int                ufo:1;
> +		int                tso6:1;
> +		int                ecn:1;
> +	} flags;

Why do you have to shadow flags that are already available in net_device?
It is bad design to replicate state in a device driver. The problem
with replicated state is that it has to be updated in both places.

-- 
