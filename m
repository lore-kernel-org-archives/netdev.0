From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net/core: generic support for disabling
 netdev features down stack
Date: Mon, 02 Nov 2015 23:41:56 -0500 (EST)
Message-ID: <20151102.234156.419769039353985647.davem@davemloft.net>
References: <1446486818-26166-1-git-send-email-jarod@redhat.com>
	<1446519359-21400-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	jiri@resnulli.us, razor@blackwall.org, mkubecek@suse.cz,
	alexander.duyck@gmail.com, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446519359-21400-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Mon,  2 Nov 2015 21:55:59 -0500

> There are some netdev features, which when disabled on an upper device,
> such as a bonding master or a bridge, must be disabled and cannot be
> re-enabled on underlying devices.
> 
> This is a rework of an earlier more heavy-handed appraoch, which simply
> disables and prevents re-enabling of netdev features listed in a new
> define in include/net/netdev_features.h, NETIF_F_UPPER_DISABLES. Any upper
> device that disables a flag in that feature mask, the disabling will
> propagate down the stack, and any lower device that has any upper device
> with one of those flags disabled should not be able to enable said flag.
> 
> Initially, only LRO is included for proof of concept, and because this
> code effectively does the same thing as dev_disable_lro(), though it will
> also activate from the ethtool path, which was one of the goals here.
 ...
> This has been successfully tested with bnx2x, qlcnic and netxen network
> cards as slaves in a bond interface. Turning LRO on or off on the master
> also turns it on or off on each of the slaves, new slaves are added with
> LRO in the same state as the master, and LRO can't be toggled on the
> slaves.
> 
> Also, this should largely remove the need for dev_disable_lro(), and most,
> if not all, of its call sites can be replaced by simply making sure
> NETIF_F_LRO isn't included in the relevant device's feature flags.
> 
> Note that this patch is driven by bug reports from users saying it was
> confusing that bonds and slaves had different settings for the same
> features, and while it won't be 100% in sync if a lower device doesn't
> support a feature like LRO, I think this is a good step in the right
> direction.
 ...
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Looks good to me, applied, thanks Jarod.
