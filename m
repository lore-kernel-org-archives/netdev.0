From: jamal <hadi@cyberus.ca>
Subject: Resend: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: 26 Mar 2005 13:35:31 -0500
Message-ID: <1111862131.1092.872.camel@jzny.localdomain>
References: <1111795927.1089.749.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-e22SSWKSAh37oPfJ/ciQ"
Cc: "David S. Miller" <davem@redhat.com>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Shinta Sugimoto <shinta.sugimoto@ericsson.com>,
        netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1111795927.1089.749.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-e22SSWKSAh37oPfJ/ciQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Apologies, The last patch had some a glitch in the filename. Dave please
apply this one instead

cheers,
jamal

--=-e22SSWKSAh37oPfJ/ciQ
Content-Disposition: attachment; filename=acq_p
Content-Type: text/plain; name=acq_p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/xfrm/xfrm_state.c	2005/03/25 17:44:43	1.1
+++ b/net/xfrm/xfrm_state.c	2005/03/25 18:55:33
@@ -774,16 +774,20 @@
 		wake_up(&km_waitq);
 }
 
+/*
+ * We send to all registered managers regardless of failure
+ * We are happy with one success
+*/
 int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
 {
-	int err = -EINVAL;
+	int err = -EINVAL, acqret = -EINVAL;
 	struct xfrm_mgr *km;
 
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list) {
-		err = km->acquire(x, t, pol, XFRM_POLICY_OUT);
-		if (!err)
-			break;
+		acqret = km->acquire(x, t, pol, XFRM_POLICY_OUT);
+		if (!acqret)
+			err = acqret;
 	}
 	read_unlock(&xfrm_km_lock);
 	return err;

--=-e22SSWKSAh37oPfJ/ciQ--
