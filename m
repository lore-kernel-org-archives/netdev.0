From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: fix software VLAN deletion
Date: Sat, 13 Feb 2016 06:08:38 -0500 (EST)
Message-ID: <20160213.060838.90896525204354915.davem@davemloft.net>
References: <1454699079-5710-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch,
	kevin.smith@elecsyscorp.com, sfeldma@gmail.com, jiri@resnulli.us,
	nikolay@cumulusnetworks.com, f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454699079-5710-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri,  5 Feb 2016 14:04:39 -0500

> The current bridge code calls switchdev_port_obj_del on a VLAN port even
> if the corresponding switchdev_port_obj_add call returned -EOPNOTSUPP.
> 
> If the DSA driver doesn't return -EOPNOTSUPP for a software port VLAN in
> its port_vlan_del function, the VLAN is not deleted. Unbridging the port
> also generates a stack trace for the same reason.
> 
> This can be quickly tested on a VLAN filtering enabled system with:
> 
>     # brctl addbr br0
>     # brctl addif br0 lan0
>     # brctl addbr br1
>     # brctl addif br1 lan1
>     # brctl delif br1 lan1
> 
> Both bridges have a default default_pvid set to 1. lan0 uses the
> hardware VLAN 1 while lan1 falls back to the software VLAN 1.
> 
> Unbridging lan1 does not delete its software VLAN, and thus generates
> the following stack trace:
 ...
> To fix this, return -EOPNOTSUPP in _mv88e6xxx_port_vlan_del instead of
> -ENOENT if the hardware VLAN doesn't exist or the port is not a member.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
