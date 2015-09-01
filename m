From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: fix device deletion order in
 mdiobus_unregister()
Date: Tue, 01 Sep 2015 15:03:04 -0700 (PDT)
Message-ID: <20150901.150304.562643685874217745.davem@davemloft.net>
References: <1441114565-2340-1-git-send-email-msalter@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddaney.cavm@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	buytenh@wantstofly.org, grant.likely@secretlab.ca
To: msalter@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441114565-2340-1-git-send-email-msalter@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Salter <msalter@redhat.com>
Date: Tue,  1 Sep 2015 09:36:05 -0400

> commit 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not
> the bus' parent.") uncovered a problem in mdiobus_unregister() which
> leads to this warning when I reboot an APM Mustang (arm64) platform:
 ...
> The problem is that mdiobus_unregister() deletes the bus device before
> unregistering the phy devices on the bus. This wasn't a problem before
> because the phys were not children of the bus:
> 
>   /sys/devices/platform/APMC0D05:00/net/eth0/xgene-mii-eth0:03
>   /sys/devices/platform/APMC0D05:00/net/eth0/xgene-mii-eth0
> 
> But now that they are:
> 
>   /sys/devices/platform/APMC0D05:00/net/eth0/xgene-mii-eth0/xgene-mii-eth0:03
> 
> when mdiobus_unregister deletes the bus device, the phy subdirs are
> removed from sysfs also. So when the phys are unregistered afterward,
> we get the warning. This patch changes the order so that phys are
> unregistered before the bus device is deleted.
> 
> Signed-off-by: Mark Salter <msalter@redhat.com>

Applied and queued up for -stable, thanks.
