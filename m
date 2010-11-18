From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] be2net: Fix to avoid firmware update when
 interface is not open.
Date: Thu, 18 Nov 2010 09:26:03 -0800 (PST)
Message-ID: <20101118.092603.104065601.davem@davemloft.net>
References: <20101118140755.GA9686@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sarveshwar.Bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50039
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758134Ab0KRRZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 12:25:39 -0500
In-Reply-To: <20101118140755.GA9686@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <Sarveshwar.Bandi@emulex.com>
Date: Thu, 18 Nov 2010 19:37:56 +0530

> Since interrupts are enabled only when open is called on the interface,
> Attempting a firmware update operation when interface is down could lead to
> partial success or failure of operation. This fix fails the request if
> netif_running is false.
> 
> Signed-off-by: Sarveshwar Bandi <Sarveshwar.Bandi@emulex.com>

These status values you are returning from be_load_fw() go all
the way back to userspace.

Therefore "-1" is not appropriate, and instead you should return
real negative errno error values such as -EINVAL, -ENODEV, and
the like.

Please fix this up and resubmit your patch.

Thank you.
