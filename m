From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/10] bnxt_en: Improve bnxt_vf_update_mac().
Date: Thu, 25 Feb 2016 12:09:21 -0500 (EST)
Message-ID: <20160225.120921.2096022701010736406.davem@davemloft.net>
References: <1456388374-1440-2-git-send-email-michael.chan@broadcom.com>
	<20160225.113128.1989544272292631983.davem@davemloft.net>
	<CACKFLi=ycecx03nPAUzVPG8-v8tvPEC5iXUtpwibVkAxhwdzMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbcBYRJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 12:09:23 -0500
In-Reply-To: <CACKFLi=ycecx03nPAUzVPG8-v8tvPEC5iXUtpwibVkAxhwdzMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Thu, 25 Feb 2016 08:57:01 -0800

> We are not registering an invalid MAC address.  We are just storing it in the
> driver's VF data structure.  There are 2 cases:
> 
> 1. VF comes up and the MAC address from firmware is 0.  The VF will
> generate random MAC.  The stored MAC address in the VF datastructure is
> 0 so that ip set link eth0 address is allowed on the VF.

Who looks at this 0 MAC address in the "VF datastructure", the driver?

Why does there need to be a 0 MAC address there to allow
->ndo_set_mac_address() to succeed on the VF at all?

This MAC address management between VFs and PFs looks unnecessarily
convoluted and complicated.  I'd hate to have to actually be a user
configuring this stuff.
