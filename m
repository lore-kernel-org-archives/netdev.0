From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: mvneta: fix usage as a module on RGMII
 configurations"
Date: Sun, 13 Apr 2014 23:14:57 -0400 (EDT)
Message-ID: <20140413.231457.1275572148025135232.davem@davemloft.net>
References: <1397380533-16012-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ezequiel.garcia@free-electrons.com,
	gregory.clement@free-electrons.com, jason@lakedaemon.net,
	andrew@lunn.ch, sebastian.hesselbarth@gmail.com, alior@marvell.com,
	tawfik@marvell.com, linux-arm-kernel@lists.infradead.org,
	stable@vger.kernel.org
To: thomas.petazzoni@free-electrons.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1397380533-16012-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Sun, 13 Apr 2014 11:15:33 +0200

> This reverts commit e3a8786c10e75903f1269474e21fe8cb49c3a670. While
> this commit allows to use the mvneta driver as a module on some
> configurations, it breaks other configurations even if mvneta is used
> built-in.
> 
> This breakage is due to the fact that on some RGMII platforms, the PCS
> bit has to be set, and on some other platforms, it has to be
> cleared. At the moment, we lack informations to know exactly the
> significance of this bit (the datasheet only says "enables PCS"), and
> so we can't produce a patch that will work on all platforms at this
> point. And since this change is breaking the network completely for
> many users, it's much better to revert it for now. We'll come back
> later with a proper fix that takes into account all platforms.
> 
> Basically:
> 
>  * Armada XP GP is configured as RGMII-ID, and needs the PCS bit to be
>    set.
>  * Armada 370 Mirabox is configured as RGMII-ID, and needs the PCS bit
>    to be cleared.
> 
> And at the moment, we don't know how to make the distinction between
> those two cases. One hint is that the Armada XP GP appears in fact to
> be using a QSGMII connection with the PHY (Quad-SGMII), but
> configuring it as SGMII doesn't work, while RGMII-ID works. This needs
> more investigation, but in the mean time, let's unbreak the network
> for all those users.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Reported-by: Arnaud Ebalard <arno@natisbad.org>
> Reported-by: Alexander Reuter <Alexander.Reuter@gmx.net>
> Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=73401

Applied, thanks for following up on this.
