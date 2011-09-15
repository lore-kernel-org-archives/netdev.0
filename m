From: David Miller <davem@redhat.com>
Subject: Re: [patch net-next-2.6] net: consolidate and fix
 ethtool_ops->get_settings calling
Date: Thu, 15 Sep 2011 17:33:39 -0400 (EDT)
Message-ID: <20110915.173339.254712565622264560.davem@redhat.com>
References: <1314905304-16485-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, fubar@us.ibm.com,
        andy@greyhouse.net, kaber@trash.net, bprakash@broadcom.com,
        JBottomley@parallels.com, robert.w.love@intel.com,
        shemminger@linux-foundation.org, decot@google.com,
        bhutchings@solarflare.com, mirq-linux@rere.qmqm.pl,
        alexander.h.duyck@intel.com, amit.salecha@qlogic.com,
        eric.dumazet@gmail.com, therbert@google.com,
        paulmck@linux.vnet.ibm.com, laijs@cn.fujitsu.com,
        xiaosuo@gmail.com, greearb@candelatech.com, loke.chetan@gmail.com,
        linux-mips@linux-mips.org, linux-scsi@vger.kernel.org,
        devel@open-fcoe.org, bridge@lists.linux-foundation.org
To: jpirko@redhat.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1314905304-16485-1-git-send-email-jpirko@redhat.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu,  1 Sep 2011 21:28:24 +0200

> This patch does several things:
> - introduces __ethtool_get_settings which is called from ethtool code and
>   from dev_ethtool_get_settings() as well.
> - dev_ethtool_get_settings() becomes rtnl wrapper for
>   __ethtool_get_settings()
> - changes calling in drivers so rtnl locking is respected. In
>   iboe_get_rate was previously ->get_settings() called unlocked. This
>   fixes it
> - introduces rtnl_lock in bnx2fc_vport_create() and fcoe_vport_create()
>   so bnx2fc_if_create() and fcoe_if_create() are called locked as they
>   are from other places.
> - prb_calc_retire_blk_tmo() in af_packet.c was not calling get_settings
>   with rtnl_lock. So use dev_ethtool_get_settings here.
> - use __ethtool_get_settings() in bonding code
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
