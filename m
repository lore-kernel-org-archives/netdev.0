From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH 05/12] team: check given MAC address, if invalid return
 -EADDRNOTAVAIL
Date: Sun, 26 Feb 2012 01:07:09 +0100
Message-ID: <20120226000709.GA2148@minipsycho.orion>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
 <1330099282-4588-6-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63357 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798Ab2BZAHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Feb 2012 19:07:19 -0500
Content-Disposition: inline
In-Reply-To: <1330099282-4588-6-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 24, 2012 at 05:01:15PM CET, danny.kukawka@bisect.de wrote:
>Check if given address is valid in .ndo_set_mac_address, if
>invalid return -EADDRNOTAVAIL as eth_mac_addr() already does
>if is_valid_ether_addr() fails.
>
>Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
>---
> drivers/net/team/team.c |    3 +++
> 1 files changed, 3 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index 8f81805..788650c 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -868,6 +868,9 @@ static int team_set_mac_address(struct net_device *dev, void *p)
> 	struct team_port *port;
> 	struct sockaddr *addr = p;
> 
>+	if (!is_valid_ether_addr(addr->sa_data))
>+		return -EADDRNOTAVAIL;
>+


Wouldn't it be better to do this in one place? dev_set_mac_address()
seems like a good place...

Jirka


> 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
> 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
> 	rcu_read_lock();
>-- 
>1.7.8.3
>
