From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 15:25:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1087424716.3351.60.camel@sfeldma-mobl2.dsl-verizon.net>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com>
	 <40CF263E.70009@home.nl>
	 <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net>
	 <40D08769.3070106@home.nl>
	 <1087412780.3351.34.camel@sfeldma-mobl2.dsl-verizon.net>
	 <40D0A446.8010607@pobox.com>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jkmaline@cc.hut.fi, jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Gertjan van Wingerde <gwingerde@home.nl>
In-Reply-To: <40D0A446.8010607@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-06-16 at 12:49, Jeff Garzik wrote:
> I apologize for not responding earlier...
> 
> ethtool is the wrong direction for a few reasons,
> * I really should have done ethtool via netlink
> * We want to move away from pretending that 802.3 == 802.11, and using 
> ethtool only serves to reinforce an association we don't want to make. 
> "everything is ethernet" isn't really true :)

Ok, then Gertjan was on track with his earlier post introducing
wlantool_ops.  Scratch the ethtool idea, my bad.

Gertjan, can we make the wlantool_ops more purpose-specific as Jeff
suggests?

 struct wlantool_ops {
     int  (*commit)(struct net_device *);
     void (*get_name)(struct net_device *, struct wlantool_name *);
-    int  (*get_nwid)(struct net_device *, struct wlantool_param *);
-    int  (*set_nwid)(struct net_device *, struct wlantool_param *);
+    u16  (*get_nwid)(struct net_device *);
+    void (*set_nwid)(struct net_device *, u16);
     int  (*get_freq)(struct net_device *, struct wlantool_freq *);
     int  (*set_freq)(struct net_device *, struct wlantool_freq *);
-    int  (*get_mode)(struct net_device *, struct wlantool_mode *);
-    int  (*set_mode)(struct net_device *, struct wlantool_mode *);
-    int  (*get_sens)(struct net_device *, struct wlantool_param *); 
-    int  (*set_sens)(struct net_device *, struct wlantool_param *);
+    u32  (*get_mode)(struct net_device *);
+    void (*set_mode)(struct net_device *, u32);
+    u16  (*get_sens)(struct net_device *); 
+    void (*set_sens)(struct net_device *, u16);
     <etc>
 };

-scott
