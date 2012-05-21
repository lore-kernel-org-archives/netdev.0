From: Gustavo Padovan <gustavo@padovan.org>
Subject: Re: [RFC/PATCH] Bluetooth: prevent double l2cap_chan_destroy
Date: Mon, 21 May 2012 13:21:37 -0300
Message-ID: <20120521162137.GE16942@joana>
References: <4FB992C8.8090105@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Minho Ban <mhban@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:40186 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628Ab2EUQVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 12:21:45 -0400
Content-Disposition: inline
In-Reply-To: <4FB992C8.8090105@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Minho,

* Minho Ban <mhban@samsung.com> [2012-05-21 09:56:40 +0900]:

> l2cap_sock_kill can be called in l2cap_sock_release and l2cap_sock_close_cb
> either. This lead l2cap_chan_destroy to be called twice for same channel.
> To prevent double list_del and double chan_put, chan_destroy should be protected
> with chan->refcnt and chan_list_lock so that reentrance could be forbidden.

Even if l2cap_sock_kill() is called twice it will call l2cap_chan_destroy()
only once. If this is not happening we just have a broken piece of code
somewhere else and not here.

	Gustavo
