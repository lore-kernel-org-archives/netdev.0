From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next v3 15/17] bridge: add new hwmode swdev
Date: Tue, 25 Nov 2014 11:17:33 -0500
Message-ID: <20141125161733.GI27416@gospo.rtplab.test>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-16-git-send-email-jiri@resnulli.us>
 <5474A83F.7040006@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	bcrl@kvack.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48077 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbaKYQRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:17:40 -0500
Content-Disposition: inline
In-Reply-To: <5474A83F.7040006@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 08:03:11AM -0800, Roopa Prabhu wrote:
> On 11/25/14, 2:28 AM, Jiri Pirko wrote:
> >From: Scott Feldman <sfeldma@gmail.com>
> >
> >Current hwmode settings are "vepa" or "veb".  These are for NIC interfaces
> >with basic bridging function offloaded to HW.  Add new "swdev" for full
> >switch device offloads.
> 
> still voting for a generic feature flag like NETIF_F_HW_OFFLOAD for use by
> bridge/bond/vxlan. I can resubmit my patch that does this.

I know it is _early_ to propose this, but I would even suggest this:

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 8e30685..6cea162 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -124,6 +124,7 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
+#define NETIF_F_HW_SWITCHING	__NETIF_F(HW_SWITCHING)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2cb7724..ca5a5e1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1508,7 +1508,7 @@ struct net_device {
 	netdev_features_t	hw_features;
 	netdev_features_t	wanted_features;
 	netdev_features_t	vlan_features;
-	netdev_features_t	hw_enc_features;
+	netdev_features_t	offload_features;
 	netdev_features_t	mpls_features;
 
 	int			ifindex;
> >
> >Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> >Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> >---
> >new in v3
> >---
> >  include/uapi/linux/if_bridge.h | 1 +
> >  1 file changed, 1 insertion(+)
> >
> >diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
> >index da17e45..60425ca 100644
> >--- a/include/uapi/linux/if_bridge.h
> >+++ b/include/uapi/linux/if_bridge.h
> >@@ -105,6 +105,7 @@ struct __fdb_entry {
> >  #define BRIDGE_MODE_VEB		0	/* Default loopback mode */
> >  #define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
> >+#define BRIDGE_MODE_SWDEV       2       /* Full switch device offload */
> >  /* Bridge management nested attributes
> >   * [IFLA_AF_SPEC] = {
> 
