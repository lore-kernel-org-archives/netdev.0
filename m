From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v1 0/6] Add fec1 and fec2 support for i.MX7d sdb board
Date: Thu, 20 Aug 2015 14:14:24 -0700
Message-ID: <55D64330.4020503@gmail.com>
References: <1439962444-27486-1-git-send-email-b38611@freescale.com> <20150820.140531.1320709021949935376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shawnguo@kernel.org,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>, b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35073 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbbHTVQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:16:49 -0400
Received: by pdob1 with SMTP id b1so18315081pdo.2
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 14:16:49 -0700 (PDT)
In-Reply-To: <20150820.140531.1320709021949935376.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/08/15 14:05, David Miller wrote:
> From: Fugang Duan <b38611@freescale.com>
> Date: Wed, 19 Aug 2015 13:33:58 +0800
> 
>> The patch series is to add fec support for i.MX7d sdb board. Since i.MX7d fec ip is
>> the same as i.MX6SX, so there have no change for driver itself.
>>
>> Patch#1: add bcm54220 PHY ID entry into brcmphy.h file.
> 
> This is completely, and utterly, pointless.
> 
> The only reason a PHY ID should be defined in brcmphy.h is so that it can
> be used in the broadcom.c PHY driver or similar.
> 
> If there is no user in the tree, there is no reason to add it to the
> header file.

There is a valid reason for which you may have a PHY id, which is
defining a PHY fixup in your platform code like Andy is doing, however,
this should not be used in conjunction with the Generic PHY driver,
because this driver has absolutely no clue about your PHY fixup, and
this could create at best inconsistencies in how the fixup is managed
later on.

At the very least, I would like to see a change to
drivers/net/phy/broadcom.c which identifies this PHY id, and eventually
just invokes the genphy_* functions where relevant.
-- 
Florian
