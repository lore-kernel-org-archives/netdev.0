From: jamal <hadi@cyberus.ca>
Subject: Re: Resend: Re: PATCH: IPSEC acquire in presence of multiple
	managers
Date: 27 Mar 2005 14:01:06 -0500
Message-ID: <1111950066.1090.930.camel@jzny.localdomain>
References: <1111795927.1089.749.camel@jzny.localdomain>
	 <1111862131.1092.872.camel@jzny.localdomain>
	 <20050326192740.GA9638@gondor.apana.org.au>
	 <1111867995.1089.918.camel@jzny.localdomain>
	 <20050327082130.GA13601@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-2bLl/Kne/1vRBDbYUW1b"
Cc: "David S. Miller" <davem@redhat.com>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Shinta Sugimoto <shinta.sugimoto@ericsson.com>,
        netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050327082130.GA13601@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-2bLl/Kne/1vRBDbYUW1b
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2005-03-27 at 03:21, Herbert Xu wrote:
> On Sat, Mar 26, 2005 at 03:13:15PM -0500, jamal wrote:
> > 
> > fair enough. You seem to have no major issues with the patch0 that i
> > sent. I can submit that instead to Dave with the few tweaks + this
> > change. Sounds good?
> 

Hrm - Ive made a few changes since we last spoke (changed the cb
structure i defined) and i dont want the patch to be huge. 

So Dave if you are reading this apply the reattached patch and i will
work against it from now on.

cheers,
jamal

--=-2bLl/Kne/1vRBDbYUW1b
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

--=-2bLl/Kne/1vRBDbYUW1b--
