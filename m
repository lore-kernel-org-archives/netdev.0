From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ipv4: fix lock usage in udp_ioctl
Date: Wed, 14 Jun 2006 15:16:17 -0700 (PDT)
Message-ID: <20060614.151617.122788798.davem@davemloft.net>
References: <20060614194305.GB10391@osiris.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mingo@elte.hu, fpavlic@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30189
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932408AbWFNWP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 18:15:59 -0400
To: heiko.carstens@de.ibm.com
In-Reply-To: <20060614194305.GB10391@osiris.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Wed, 14 Jun 2006 21:43:05 +0200

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Fix lock usage in udp_ioctl().
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

More likely the qeth driver shouldn't call into the socket code in
hardware interrupt context.  From your logs that's what it seems is
happening.

The socket receive queue should only be touched in software
interrupt context, never in hardware interrupt context.  That's
why the locking does BH disabling at best.
