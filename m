From: jamal <hadi@cyberus.ca>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: 03 Apr 2005 12:36:35 -0400
Message-ID: <1112546194.1096.401.camel@jzny.localdomain>
References: <1112319441.1089.83.camel@jzny.localdomain>
	 <20050401042106.GA27762@gondor.apana.org.au>
	 <1112353398.1096.116.camel@jzny.localdomain>
	 <20050401114258.GA2932@gondor.apana.org.au>
	 <1112358278.1096.160.camel@jzny.localdomain>
	 <20050401123554.GA3468@gondor.apana.org.au>
	 <1112403845.1088.14.camel@jzny.localdomain>
	 <20050402012813.GA24575@gondor.apana.org.au>
	 <1112406164.1088.54.camel@jzny.localdomain>
	 <20050402014619.GB24861@gondor.apana.org.au>
	 <1112469601.1088.173.camel@jzny.localdomain>
	 <1112538718.1096.394.camel@jzny.localdomain>  <42501027.6010609@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-HzY6ovv3o1agHd1AZ7ya"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42501027.6010609@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-HzY6ovv3o1agHd1AZ7ya
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Masahide,

Attached is incremental patch on top of the one posted earlier.
Looks ok from my basic testing. Please run it against your tests
and see if it stands.

cheers,
jamal

On Sun, 2005-04-03 at 11:47, Patrick McHardy wrote:
> You call these functions from both softirq- and user-context, so you
> need to protect against BHs.
> 
> Regards
> Patrick
> 

--=-HzY6ovv3o1agHd1AZ7ya
Content-Disposition: attachment; filename=ipsec-event-take2-1-1
Content-Type: text/plain; name=ipsec-event-take2-1-1; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/xfrm/xfrm_state.c	2005/04/03 16:30:31	1.2
+++ b/net/xfrm/xfrm_state.c	2005/04/03 16:31:27
@@ -251,20 +251,20 @@
 {
 	struct xfrm_mgr *km;
 
-	read_lock(&xfrm_km_lock);
+	read_lock_bh(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list)
 		if (km->notify_policy)
 			km->notify_policy(xp, dir, c);
-	read_unlock(&xfrm_km_lock);
+	read_unlock_bh(&xfrm_km_lock);
 }
 
 void km_state_notify(struct xfrm_state *x, struct km_event *c)
 {
 	struct xfrm_mgr *km;
-	read_lock(&xfrm_km_lock);
+	read_lock_bh(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list)
 		km->notify(x, c);
-	read_unlock(&xfrm_km_lock);
+	read_unlock_bh(&xfrm_km_lock);
 }
 
 EXPORT_SYMBOL(km_policy_notify);

--=-HzY6ovv3o1agHd1AZ7ya--
