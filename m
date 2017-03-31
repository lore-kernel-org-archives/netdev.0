From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: fix build error with devlink build as
 module
Date: Fri, 31 Mar 2017 15:34:58 +0200
Message-ID: <20170331133458.GF22609@lunn.ch>
References: <20170331094452.32578-1-tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
To: Tobias Regnery <tobias.regnery@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170331094452.32578-1-tobias.regnery@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 31, 2017 at 11:44:52AM +0200, Tobias Regnery wrote:
> After commit 96567d5dacf4 ("net: dsa: dsa2: Add basic support of devlink")
> I see the following link error with CONFIG_NET_DSA=y and CONFIG_NET_DEVLINK=m:
> 
> net/built-in.o: In function 'dsa_register_switch':
> (.text+0xe226b): undefined reference to `devlink_alloc'
> net/built-in.o: In function 'dsa_register_switch':
> (.text+0xe2284): undefined reference to `devlink_register'
> net/built-in.o: In function 'dsa_register_switch':
> (.text+0xe243e): undefined reference to `devlink_port_register'
> net/built-in.o: In function 'dsa_register_switch':
> (.text+0xe24e1): undefined reference to `devlink_port_register'
> net/built-in.o: In function 'dsa_register_switch':
> (.text+0xe24fa): undefined reference to `devlink_port_type_eth_set'
> net/built-in.o: In function 'dsa_dst_unapply.part.8':
> dsa2.c:(.text.unlikely+0x345): undefined reference to 'devlink_port_unregister'
> dsa2.c:(.text.unlikely+0x36c): undefined reference to 'devlink_port_unregister'
> dsa2.c:(.text.unlikely+0x38e): undefined reference to 'devlink_port_unregister'
> dsa2.c:(.text.unlikely+0x3f2): undefined reference to 'devlink_unregister'
> dsa2.c:(.text.unlikely+0x3fb): undefined reference to 'devlink_free'
> 
> Fix this by adding a dependency on MAY_USE_DEVLINK so that CONFIG_NET_DSA
> get switched to be build as module when CONFIG_NET_DEVLINK=m.
> 
> Fixes: 96567d5dacf4 ("net: dsa: dsa2: Add basic support of devlink")
> Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>

Hi Tobias

0-day just found the same issue as well.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
    Andrew
