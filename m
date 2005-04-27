From: jamal <hadi@cyberus.ca>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 08:24:17 -0400
Message-ID: <1114604657.7670.22.camel@localhost.localdomain>
References: <1114602874.7670.4.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-svPqSGhbObaErkWu9yim"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1114602874.7670.4.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-svPqSGhbObaErkWu9yim
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2005-27-04 at 07:54 -0400, Jamal Hadi Salim wrote:
> Herbert,
> 
> I think this is a reasonable thing to have. I should be able to update
> (just like delete or get) a policy by id. And that it trumps a selector
> when both are specified..
> I am assuming ids are unique - otherwise we have a serious problem.
> If this patch looks good, please add it to your patch collection that
> you are queueing for Dave; btw - is that stuff supposed to show up
> around .13?
> 

Sorry, should have tried to compile first ;->

here it is. I will test in 5 minutes or so.

cheers,
jamal

--=-svPqSGhbObaErkWu9yim
Content-Disposition: attachment; filename=polid_p
Content-Type: text/plain; name=polid_p; charset=utf-8
Content-Transfer-Encoding: 7bit

--- /usr/src/26117-mod/net/xfrm/xfrm_policy.c	2005/04/27 11:32:13	1.1
+++ /usr/src/26117-mod/net/xfrm/xfrm_policy.c	2005/04/27 12:23:03
@@ -345,7 +345,9 @@
 
 	write_lock_bh(&xfrm_policy_lock);
 	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
-		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0) {
+		if (!delpol && 
+		((!excl && policy->id && (policy->index == pol->index)) || 
+		 (memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0))) {
 			if (excl) {
 				write_unlock_bh(&xfrm_policy_lock);
 				return -EEXIST;

--=-svPqSGhbObaErkWu9yim--
