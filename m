From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]: Fix off-by-one in max protocol-type check
Date: Mon, 31 May 2004 01:41:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40BA7111.7030307@trash.net>
References: <40B71A1C.5080400@trash.net>	<40B71ABD.5060600@trash.net> <20040529123829.10778ffe.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080900070009090006000609"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040529123829.10778ffe.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080900070009090006000609
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

David S. Miller wrote:
>>Patrick McHardy wrote:
>>
>>>This patch fixes an off-by-one in inet_register_protosw and
>>>inet6_register_protosw. inetsw is an array of size SOCK_MAX,
>>>the check allows access to index SOCK_MAX. Patch applies
>>>to 2.4 and 2.6.
>>
>>Forgot the patch, sorry ;)
> 
> 
> Applied.
> 

Judging from 2.4.27-pre4 changelog, you forgot to apply this
patch to 2.4. Patch from 2.6 attached, it applies with some
offset.

Regards
Patrick

--------------080900070009090006000609
Content-Type: text/x-patch;
 name="protocol-type-off-by-one.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="protocol-type-off-by-one.diff"

ChangeSet 1.1763, 2004/05/29 12:38:17-07:00, kaber@trash.net

	[IPV4,6]: Fix off-by-one in max protocol-type check



 ipv4/af_inet.c  |    2 +-
 ipv6/af_inet6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)


diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	2004-05-29 14:14:46 -07:00
+++ b/net/ipv4/af_inet.c	2004-05-29 14:14:46 -07:00
@@ -978,7 +978,7 @@
 
 	spin_lock_bh(&inetsw_lock);
 
-	if (p->type > SOCK_MAX)
+	if (p->type >= SOCK_MAX)
 		goto out_illegal;
 
 	/* If we are trying to override a permanent protocol, bail. */
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-05-29 14:14:46 -07:00
+++ b/net/ipv6/af_inet6.c	2004-05-29 14:14:46 -07:00
@@ -572,7 +572,7 @@
 
 	spin_lock_bh(&inetsw6_lock);
 
-	if (p->type > SOCK_MAX)
+	if (p->type >= SOCK_MAX)
 		goto out_illegal;
 
 	/* If we are trying to override a permanent protocol, bail. */

--------------080900070009090006000609--
