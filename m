From: Bert Vermeulen <bert@biot.com>
Subject: Re: [PATCH net-next 0/3] net: phy: broken turn-around support
Date: Tue, 12 May 2015 22:43:26 +0200
Message-ID: <555265EE.9000009@biot.com>
References: <1431442563-10218-1-git-send-email-bert@biot.com> <1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jogo@openwrt.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kiutl.biot.com ([31.172.244.210]:36996 "EHLO kiutl.biot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932574AbbELUnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 16:43:51 -0400
Received: from spamd by kiutl.biot.com with sa-checked (Exim 4.83)
	(envelope-from <bert@biot.com>)
	id 1YsH1i-0007Ww-A2
	for netdev@vger.kernel.org; Tue, 12 May 2015 22:43:42 +0200
In-Reply-To: <1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2015 07:33 PM, Florian Fainelli wrote:
> Hi all,
> 
> This is an attempt at solving the broken turn-around problem in a way that
> is not specific to the mdio-gpio driver, since it affects different kinds of
> platforms.
> 
> We cannot make that localized to PHY device drivers because probing the PHY
> device which has a broken turn-around can fail as early as in get_phy_id(),
> therefore we need a bit of help from Device Tree/platform_data.

That is indeed a better place to put that ignore-ta flag, and the device
tree support is of course a big improvement over the previous patch as well.

But it's still too big a hammer to hit the AR8316 problem with, I think.
Just like the previous patch, this disables checking TA on _all_ reads, but
I really only need it disabled on the first read.

Are you saying you've seen other systems with this TA problem? Did those
have problems after more than just the first read?


-- 
Bert Vermeulen        bert@biot.com          email/xmpp
