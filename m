From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 13 Jul 2009 10:49:50 -0700 (PDT)
Message-ID: <20090713.104950.121936768.davem@davemloft.net>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37112
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752445AbZGMRtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 13:49:46 -0400
In-Reply-To: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 3 May 2009 21:03:01 -0700

> @@ -758,6 +758,8 @@ struct net_device
>  	void			*ax25_ptr;	/* AX.25 specific data */
>  	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
>  						   assign before registering */
> +	u16			*rps_map;
> +	int			rps_map_len;
> 
>  /*
>   * Cache line mostly used on receive path (including eth_type_trans())

So essentially this table is a user defined (via sysctl) group of cpus
among which to distribute incoming traffic for a device, right?

Why not take this to it's logical end point, which is to monitor
transmits using a tiny flow lookup table, and map receives of the same
flow to the same cpu?

You can even "cheat" and not store the whole flow key in the small
lookup table, just use the resulting hash value as the key.  Also,
if "best effort" is considered OK you can even do away with hash
chaining as well, further decreasing the space cost of the table.

If your goal is to steer traffic to the cpu on which the receiving
application is operating, that seems to me to be the only way to
reliably and consistently hit that target.
