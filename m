From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: fix port VLAN maps
Date: Fri, 29 Jan 2016 19:42:15 -0800 (PST)
Message-ID: <20160129.194215.1162453295129740691.davem@davemloft.net>
References: <1454018077-11222-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch,
	rmk+kernel@arm.linux.org.uk, kevin.smith@elecsyscorp.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454018077-11222-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 28 Jan 2016 16:54:37 -0500

> Currently the port based VLAN maps should be configured to allow every
> port to egress frames on all other ports, except themselves.
> 
> The debugfs interface shows that they are misconfigured. For instance, a
> 7-port switch has the following content in the related register 0x06:
> 
>        GLOBAL GLOBAL2 SERDES   0    1    2    3    4    5    6
>     ...
>     6:  1fa4    1f0f       4   7f   7e   7d   7c   7b   7a   79
>     ...
> 
> This means that port 3 is allowed to talk to port 2-6, but cannot talk
> to ports 0 and 1. With this fix, port 3 can correctly talk to all ports
> except 3 itself:
> 
>        GLOBAL GLOBAL2 SERDES   0    1    2    3    4    5    6
>     ...
>     6:  1fa4    1f0f       4   7e   7d   7b   77   6f   5f   3f
>     ...
> 
> Fixes: ede8098d0fef ("net: dsa: mv88e6xxx: bridges do not need an FID")
> Reported-by: Kevin Smith <kevin.smith@elecsyscorp.com>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
