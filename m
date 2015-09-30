From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dsa: mv88e6xxx: Fix unsigned/signed issue
Date: Tue, 29 Sep 2015 21:13:18 -0700 (PDT)
Message-ID: <20150929.211318.1846763983800250099.davem@davemloft.net>
References: <1443484428-29075-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbbI3ENT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:13:19 -0400
In-Reply-To: <1443484428-29075-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 29 Sep 2015 01:53:48 +0200

> commit dea870242a9c ("dsa: mv88e6xxx: Allow speed/duplex of port to be
> configured") leads to the following static checker warning:
> 
>         drivers/net/dsa/mv88e6xxx.c:585 mv88e6xxx_adjust_link()
>         warn: unsigned 'ret' is never less than zero.
> 
> drivers/net/dsa/mv88e6xxx.c
>    573  void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
>    574                             struct phy_device *phydev)
>    575  {
>    576          struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>    577          u32 ret, reg;
>    578
>    579          if (!phy_is_pseudo_fixed_link(phydev))
>    580                  return;
>    581
>    582          mutex_lock(&ps->smi_mutex);
>    583
>    584          ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
>    585          if (ret < 0)
> 
> Make ret an int, which is the return type for _mv88e6xxx_reg_read()
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
