From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT] Networking
Date: Thu, 2 May 2013 10:36:49 +0200
Message-ID: <20130502083619.GA22010@macbook.localnet>
References: <CA+55aFxoP1vybnqdDwGmd-m0j=x=KDm7GHV6J1i8wGOaU0=5qw@mail.gmail.com>
 <20130502.024552.1513488878160820332.davem@davemloft.net>
 <20130502070256.GA29502@macbook.localnet>
 <20130502.041625.412316202038784117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="p4qYPpj5QlsIQJ0K"
Cc: torvalds@linux-foundation.org, hayeswang@realtek.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130502.041625.412316202038784117.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--p4qYPpj5QlsIQJ0K
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 02, 2013 at 04:16:25AM -0400, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 2 May 2013 09:03:37 +0200
> 
> > I'll also have a look at this.
> 
> By the mere existence of /sys/devices/${DEV_PATH}/net/${netdev_name}/flags
> we have to preserve the bit layout.
> 
> So Linus was right.
> 
> So network manager is probably reading that flags sysfs file and
> interpreting it.

Right, that seems plausible. 

> I'll fix the layout to how it was before.

I also found one spot in net/core/dev.c which was using an int for the
features. Patch attached.



--p4qYPpj5QlsIQJ0K
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="01.patch"

commit d0ed96507b21da2668766207f68518bef3193111
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu May 2 10:35:02 2013 +0200

    net: use netdev_features_t in skb_needs_linearize()
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 4040673..40b1fad 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2456,7 +2456,7 @@ EXPORT_SYMBOL(netif_skb_features);
  *	2. skb is fragmented and the device does not support SG.
  */
 static inline int skb_needs_linearize(struct sk_buff *skb,
-				      int features)
+				      netdev_features_t features)
 {
 	return skb_is_nonlinear(skb) &&
 			((skb_has_frag_list(skb) &&

--p4qYPpj5QlsIQJ0K--
