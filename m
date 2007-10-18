From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Let inet_diag and friends autoload
Date: Wed, 17 Oct 2007 19:51:25 -0700 (PDT)
Message-ID: <20071017.195125.15264659.davem@davemloft.net>
References: <200710161728.23733.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60692
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760204AbXJRCv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:51:26 -0400
In-Reply-To: <200710161728.23733.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jean Delvare <jdelvare@suse.de>
Date: Tue, 16 Oct 2007 17:28:23 +0200

> By adding module aliases to inet_diag, tcp_diag and dccp_diag, we let
> them load automatically as needed. This makes tools like "ss" run
> faster.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> ---
> The alias naming scheme for tcp_diag and dccp_diag follows what was
> done for dccp_ipv4 and dccp_ipv6.

I'm concerned it might be dangerous to load the module in
this context, the RTNL semaphore is held and the module we
are requesting could easily try to take it and deadlock.

Currently we are lucky and this won't happen, but if the sub-proto
registration is every changed to do so, it will be a nightmare for
whoever is so unlucky to try and debug it.
