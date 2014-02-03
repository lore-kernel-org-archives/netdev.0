From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH net] net: phy: ensure Gigabit features are masked off if requested
Date: Tue, 4 Feb 2014 02:58:11 +0400
Message-ID: <CAMo8BfJvqewCSK8MZAHya02O0EXnCS4QkzPrCmuYp8PO1f=7pw@mail.gmail.com>
References: <1391459746-2631-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:65360 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbaBCW6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 17:58:12 -0500
Received: by mail-ob0-f170.google.com with SMTP id va2so8703999obc.29
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 14:58:12 -0800 (PST)
In-Reply-To: <1391459746-2631-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 4, 2014 at 12:35 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> When a Gigabit PHY device is connected to a 10/100Mbits capable Ethernet
> MAC, the driver will restrict the phydev->supported modes to mask off
> Gigabit. If the Gigabit PHY comes out of reset with the Gigabit features
> set by default in MII_CTRL1000, it will keep advertising these feature,
> so by the time we call genphy_config_advert(), the condition on
> phydev->supported having the Gigabit features on is false, and we do not
> update MII_CTRL1000 with updated values, and we keep advertising Gigabit
> features, eventually configuring the PHY for Gigabit whilst the Ethernet
> MAC does not support that.
>
> This patches fixes the problem by ensuring that the Gigabit feature bits
> are always cleared in MII_CTRL1000, if the PHY happens to be a Gigabit
> PHY, and then, if Gigabit features are supported, setting those and
> updating MII_CTRL1000 accordingly.
>
> Reported-by: Max Filippov <jcmvbkbc@gmail.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/phy/phy_device.c | 38 ++++++++++++++++++++++++--------------
>  1 file changed, 24 insertions(+), 14 deletions(-)

Tested-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max
