From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: NULL pointer dereference in veth_stats_one
Date: Fri, 04 Jan 2013 11:23:26 -0800
Message-ID: <1357327406.1678.2139.camel@edumazet-glaptop>
References: <20130104105955.GA3663@raven>
	 <1357314320.1678.1414.camel@edumazet-glaptop>
	 <1357316231.1678.1528.camel@edumazet-glaptop>
	 <1357323443.2693.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Parkin <tparkin@katalix.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:61200 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754060Ab3ADTX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 14:23:29 -0500
Received: by mail-da0-f53.google.com with SMTP id x6so7613227dac.12
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 11:23:29 -0800 (PST)
In-Reply-To: <1357323443.2693.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-04 at 18:17 +0000, Ben Hutchings wrote:

> This possibly needs some memory barriers to properly synchronise with
> veth_newlink().  But can you not move initialisation of the peer
> pointers before registration of the devices in veth_newlink(), so that
> veth_get_stats64() cannot be called before they are initialised?

The ->peer pointer cannot change once set. ( its never cleared )

So the problem would not be in veth_newlink(), but might be in
veth_dellink()

It seems we would have a problem in veth_get_ethtool_stats() already...

More generally, what prevents a get_stats() being called while a
dellink() (-> veth_dev_free() -> free_percpu()) is done ?

(Same thing is done for tunnel/dummy stats percpu data)
