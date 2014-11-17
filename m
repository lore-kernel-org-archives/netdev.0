From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next 01/14] net: provide a per host RSS key generic infrastructure
Date: Sun, 16 Nov 2014 22:46:43 -0800
Message-ID: <87wq6uiass.fsf@tassilo.jf.intel.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
	<1416147798-16561-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2615 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997AbaKQGrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 01:47:19 -0500
In-Reply-To: <1416147798-16561-2-git-send-email-edumazet@google.com> (Eric
	Dumazet's message of "Sun, 16 Nov 2014 06:23:05 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <edumazet@google.com> writes:

> Some drivers use a constant (and well known key), some drivers use a random
> key per port, making bonding setups hard to tune. Well known keys increase
> attack surface, considering that number of queues is usually a power of two.

Wouldn't it be better to have some kernel facility to query on what
port a given mapping would end up rather than exporting
the key? Similar to querying the rounting table.
That would be more abstract.

> +	{
> +		.procname	= "netdev_rss_key",
> +		.data		= &netdev_rss_key,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0444,

Surely 0400 ? After all it's a kind a "secret"

-Andi
