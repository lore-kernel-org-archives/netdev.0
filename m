From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 15/15] i40e: correctly setup ARQ descriptors
Date: Tue, 07 Jan 2014 15:34:24 -0500 (EST)
Message-ID: <20140107.153424.1505811913811866788.davem@davemloft.net>
References: <1389087149-27962-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1389087149-27962-16-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbaAGUe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:34:28 -0500
In-Reply-To: <1389087149-27962-16-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  7 Jan 2014 01:32:29 -0800

> +	memset((void *)desc, 0, sizeof(struct i40e_aq_desc));

This is terrible.

First of all, no pointer need ever be cast when passed into memset()
because it accepts void * which is cleanly implicitly cast from any
pointer type.  That's the whole reason memset accepts a void pointer,
so people don't need to ever cast the argument.

Secondly, using an explicit type to compute the size of the third
argument is error prone.

So please code this as the canonical:

	memset(desc, 0, sizeof(*desc));

Thanks.
