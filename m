From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]: Fix off-by-one in max protocol-type check
Date: Fri, 28 May 2004 12:55:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B71ABD.5060600@trash.net>
References: <40B71A1C.5080400@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000107050809030105030804"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <40B71A1C.5080400@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000107050809030105030804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> This patch fixes an off-by-one in inet_register_protosw and
> inet6_register_protosw. inetsw is an array of size SOCK_MAX,
> the check allows access to index SOCK_MAX. Patch applies
> to 2.4 and 2.6.

Forgot the patch, sorry ;)


> 
> Regards
> Patrick
> 


--------------000107050809030105030804
Content-Type: text/x-patch;
 name="protocol-type-off-by-one.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="protocol-type-off-by-one.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/28 12:24:03+02:00 kaber@trash.net 
#   [IPV4,6]: Fix off-by-one in max protocol-type check
# 
# net/ipv6/af_inet6.c
#   2004/05/28 12:23:56+02:00 kaber@trash.net +1 -1
#   [IPV4,6]: Fix off-by-one in max protocol-type check
# 
# net/ipv4/af_inet.c
#   2004/05/28 12:23:56+02:00 kaber@trash.net +1 -1
#   [IPV4,6]: Fix off-by-one in max protocol-type check
# 
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	2004-05-28 12:35:06 +02:00
+++ b/net/ipv4/af_inet.c	2004-05-28 12:35:06 +02:00
@@ -978,7 +978,7 @@
 
 	spin_lock_bh(&inetsw_lock);
 
-	if (p->type > SOCK_MAX)
+	if (p->type >= SOCK_MAX)
 		goto out_illegal;
 
 	/* If we are trying to override a permanent protocol, bail. */
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-05-28 12:35:06 +02:00
+++ b/net/ipv6/af_inet6.c	2004-05-28 12:35:06 +02:00
@@ -572,7 +572,7 @@
 
 	spin_lock_bh(&inetsw6_lock);
 
-	if (p->type > SOCK_MAX)
+	if (p->type >= SOCK_MAX)
 		goto out_illegal;
 
 	/* If we are trying to override a permanent protocol, bail. */

--------------000107050809030105030804--
