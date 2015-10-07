From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/3] net: remove dsa.h from netdevice.h
Date: Tue, 06 Oct 2015 17:42:28 -0700
Message-ID: <56146A74.8050807@gmail.com>
References: <1444168467-10293-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444168467-10293-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/10/15 14:54, Vivien Didelot wrote:
> In order to push switchdev objects down to DSA drivers, I need to include
> switchdev.h in dsa.h. But compilation fails because of a circular dependency
> issue, since dsa.h is also included in linux/netdevice.h.

Just for the record, what does this circular dependency looks like? Last
I tried something in that front, I ended-up forward declaring the
'switchdev_obj' structure, but that was weeks ago before the whole
restructuring, so could be pointless now.

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
> 
> Vivien Didelot (3):
>   net: dsa: add uses_hw_tag
>   net: dsa: include dsa.h in dsa_priv.h
>   net: remove dsa.h include from linux/netdevice.h
> 
>  include/linux/netdevice.h | 9 ++++++---
>  include/net/dsa.h         | 5 -----
>  net/dsa/dsa.c             | 1 +
>  net/dsa/dsa_priv.h        | 1 +
>  4 files changed, 8 insertions(+), 8 deletions(-)
> 


-- 
Florian
