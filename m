From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH 1/1] Fix 802.3az compatible issue
Date: Thu, 2 Jun 2011 03:50:30 +0800
Message-ID: <20110601193538.M12007@cooldavid.org>
References: <201106011250.p51Coox8031239@jmr105.jmicron.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: <netdev@vger.kernel.org>, <devinchiu@jmicron.com>
To: "Aries Lee" <arieslee@jmicron.com>,
	"'David Rehner'" <dave@daveonline.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:51423 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932240Ab1FAT5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 15:57:40 -0400
In-Reply-To: <201106011250.p51Coox8031239@jmr105.jmicron.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Jun 2011 20:50:50 +0800, Aries Lee wrote
> The older JMicron NIC chip -- Jme251A, can NOT connect with a linking
> partner with "802.3az" feature in 1000M speed.
> More specifically speaking, it's HW design has a problem in
> auto-negotiation if the linking partner is running 802.3az function.
> 
> This "Auto speed down" patch is a software workaround to avoid the user
> of older jme chip unable to connect with the linking partner with
> 802.3az function.
> If the NIC is down speed to 100M, everything is fine. But if the NIC is
> running by 1000M speed, this problem makes it unable to link up.
> 
> The algorithm of this workaround is as following:
> Setup a timer to polling when the PHY link status is down, If the
> ethernet cable was attached but auto-negotiation has not been
> accomplished for a long time (default 11 second), that mean the linking
> partner maybe running 802.3az function, driver will try to
> connect by 100M speed.
> If the link is up, then stop the timer.
> 
> Signed-off-by: arieslee <arieslee@jmicron.com>

I've already discussed about this fix approach with JMicron staff.
Personally I do not like the idea of doing "Auto Speed Down"
in driver. The driver shouldn't implicitly change the AutoNeg
setting by itself. It might confuse the sysadmin a lot. And by
design, it is not reasonable.

Their reason of still wanting to send this patch is about the
end user(Someone not familiar with network) experience. If one
can get the link, one might not care about what the driver did.

Anyway, if Davem or other senior developer is fine with this approach.
I can clean-up this patch, discuss more detail and re-submit again.

--
Guo-Fu Tseng

