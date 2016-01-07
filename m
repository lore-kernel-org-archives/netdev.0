From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 05/26] phy: improve safety of fixed-phy MII register
 reading
Date: Thu, 07 Jan 2016 11:50:36 -0800
Message-ID: <568EC18C.9050301@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zjF-00074s-1E@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36791 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbcAGTvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:51:10 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so173723956pab.3
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:51:10 -0800 (PST)
In-Reply-To: <E1a5zjF-00074s-1E@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:37, Russell King wrote:
> There is no prevention of a concurrent call to both fixed_mdio_read()
> and fixed_phy_update_state(), which can result in the state being
> modified while it's being inspected.  Fix this by using a seqcount
> to detect modifications, and memcpy()ing the state.
> 
> We remain slightly naughty here, calling link_update() and updating
> the link status within the read-side loop - which would need rework
> of the design to change.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
