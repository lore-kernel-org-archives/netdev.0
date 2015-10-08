From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: remove dsa.h from netdevice.h
Date: Thu, 08 Oct 2015 04:57:32 -0700 (PDT)
Message-ID: <20151008.045732.1781136095864323644.davem@davemloft.net>
References: <1444168467-10293-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, sfeldma@gmail.com, jiri@resnulli.us,
	f.fainelli@gmail.com, andrew@lunn.ch, narmstrong@baylibre.com,
	sergei.shtylyov@cogentembedded.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444168467-10293-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue,  6 Oct 2015 17:54:24 -0400

> In order to push switchdev objects down to DSA drivers, I need to include
> switchdev.h in dsa.h. But compilation fails because of a circular dependency
> issue, since dsa.h is also included in linux/netdevice.h.
> 
> dsa.h is included for two purposes: to have the definition of struct
> dsa_switch_tree; and to have access to dsa_uses_tagged_protocol(), used by
> netdev_uses_dsa().
> 
> This patchset forward declares struct dsa_switch_tree; adds a new uses_hw_tag
> boolean to struct net_device, which is more explicit than the DSA helper, and
> finally get rid of the dsa.h include.
> 
> With this patchset, switchdev.h can safely be included in dsa.h.

The netdevice structure is already too big, and bloating it up even more
to satisfy some include ordering issue is rather unacceptable as far as I
am concerned.

Just forward declare the pointer type, you're not dereferencing it.
