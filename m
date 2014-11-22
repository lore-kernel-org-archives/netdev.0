From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 1/2] ethtool: Support for configurable RSS
 hash function
Date: Sat, 22 Nov 2014 16:54:07 -0500 (EST)
Message-ID: <20141122.165407.641057904952001007.davem@davemloft.net>
References: <1416493610-8966-1-git-send-email-amirv@mellanox.com>
	<1416493610-8966-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, eyalpe@mellanox.com,
	thomas.lendacky@amd.com, ariel.elior@qlogic.com,
	prashant@broadcom.com, mchan@broadcom.com, hariprasad@chelsio.com,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	linux-net-drivers@solarflare.com, sshah@solarflare.com,
	sbhatewara@vmware.com, pv-drivers@vmware.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbaKVVyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 16:54:12 -0500
In-Reply-To: <1416493610-8966-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 20 Nov 2014 16:26:49 +0200

> +	/* We require at least one supported parameter to be changed and no
> +	 * change in any of the unsupported parameters
> +	 */
> +	if ((!indir && !key) || hfunc != ETH_RSS_HASH_NO_CHANGE)
> +		return -EOPNOTSUPP;
> +

I know it will make more work for you, but all of these driver
implementations of this hook should:

1) Accept hfunc of whatever hash function the chip is using,
   not just ETH_RSS_HASH_NO_CHANGE.

2) Provide an accurate hfunc value in the ->get() call.
