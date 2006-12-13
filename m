From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] drivers/net/loopback.c: convert to module_init()
Date: Tue, 12 Dec 2006 17:17:56 -0800 (PST)
Message-ID: <20061212.171756.85408589.davem@davemloft.net>
References: <20061212162435.GW28443@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50995
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932371AbWLMBR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 20:17:57 -0500
To: bunk@stusta.de
In-Reply-To: <20061212162435.GW28443@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 12 Dec 2006 17:24:35 +0100

> This patch converts drivers/net/loopback.c to using module_init().
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

I'm not %100 sure of this one, let's look at the comment you
are deleting:

> -/*
> - *	The loopback device is global so it can be directly referenced
> - *	by the network code. Also, it must be first on device list.
> - */
> -extern int loopback_init(void);
> -

in particular notice the part that says "it must be first on the
device list".

I'm not sure whether that is important any longer.  It probably isn't,
but we should verify it before applying such a patch.

Since module_init() effectively == device_initcall() for statically
built objects, which loopback always is, the Makefile ordering does
not seem to indicate to me that there is anything guarenteeing
this "first on the list" invariant.  At least not via object
file ordering.

So this gives some support to the idea that loopback_dev's position
on the device list no longer matters.
