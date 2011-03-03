From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] net/core: fix skb handling on netif serves for
 both bridge and vlan
Date: Thu, 03 Mar 2011 13:53:34 +0000
Message-ID: <1299160414.4277.49.camel@localhost>
References: <1299149713-18740-1-git-send-email-dfeng@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
To: Xiaotian Feng <dfeng@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299149713-18740-1-git-send-email-dfeng@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-03 at 18:55 +0800, Xiaotian Feng wrote:
> Consider network topology as follows:
> 
> eth0  eth1
>  |_____|
>     |
>   bond0 --- br0
>     |
>   vlan0 --- br1
> 
> bond0 serves for both br0 and vlan0, if a vlan tagged packet was sent
> to br1 through bond0, bridge handling code is seeing the packet on bond0
> and handing it off to my "legacy" bridge before vlan_tx_tag_present
> and vlan_hwaccel_do_receive even haven't a chance to look at it.
[...]

This used to work if the underlying device (bond0 in your example)
implemented VLAN tag extraction, because the VLAN group would be checked
before the bridge.  But it never worked for devices without VLAN tag
extraction.  Perhaps we should just prevent this configuration.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
