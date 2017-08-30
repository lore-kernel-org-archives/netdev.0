From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: Re: [PATCH net-next v3 0/3] NCSI VLAN Filtering Support
Date: Wed, 30 Aug 2017 14:37:21 +1000
Message-ID: <1504067841.1361.11.camel@mendozajonas.com>
References: <20170828061843.24349-1-sam@mendozajonas.com>
         <20170828.165001.1442421762159241248.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        openbmc@lists.ozlabs.org, joel@jms.id.au, benh@kernel.crashing.org,
        gwshan@linux.vnet.ibm.com, ratagupt@in.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828.165001.1442421762159241248.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-08-28 at 16:50 -0700, David Miller wrote:
> From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
> Date: Mon, 28 Aug 2017 16:18:40 +1000
> 
> > This series (mainly patch 2) adds VLAN filtering to the NCSI implementation.
> > A fair amount of code already exists in the NCSI stack for VLAN filtering but
> > none of it is actually hooked up. This goes the final mile and fixes a few
> > bugs in the existing code found along the way (patch 1).
> > 
> > Patch 3 adds the appropriate flag and callbacks to the ftgmac100 driver to
> > enable filtering as it's a large consumer of NCSI (and what I've been
> > testing on).
> > 
> > v3:   - Add comment describing change to ncsi_find_filter()
> >       - Catch NULL in clear_one_vid() from ncsi_get_filter()
> >       - Simplify state changes when kicking updated channel
> 
> Series applied.

Thanks David,

The kbuild bot caught a build error where the add/kill callbacks aren't
defined without CONFIG_NET_NCSI:

>> ERROR: "ncsi_vlan_rx_kill_vid" [drivers/net/ethernet/faraday/ftgmac100.ko] undefined!
>> ERROR: "ncsi_vlan_rx_add_vid" [drivers/net/ethernet/faraday/ftgmac100.ko] undefined!

It's a quick fixup to patch 3 as below, would you like me to send it as a v4?


diff --git a/include/net/ncsi.h b/include/net/ncsi.h
index 1f96af46df49..2b13b6b91a4d 100644
--- a/include/net/ncsi.h
+++ b/include/net/ncsi.h
@@ -36,6 +36,14 @@ int ncsi_start_dev(struct ncsi_dev *nd);
 void ncsi_stop_dev(struct ncsi_dev *nd);
 void ncsi_unregister_dev(struct ncsi_dev *nd);
 #else /* !CONFIG_NET_NCSI */
+int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+       return -ENOTTY;
+}
+int ncsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+       return -ENOTTY;
+}
 static inline struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
                                        void (*notifier)(struct ncsi_dev *nd))
 {
