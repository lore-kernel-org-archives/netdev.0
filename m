From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] kill rtnl_exlock stubs
Date: Tue, 27 Jul 2004 20:38:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4106A132.8040207@trash.net>
References: <20040727095057.78c7419c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050300050105030606070004"
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Jamal Hadi Salim <hadi@znyx.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040727095057.78c7419c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050300050105030606070004
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> Rtnetlink has some macro's that are relics from earlier locking.
> They are only used a couple of places so are easy to kill.

The variable "exclusive" in rtnetlink_rcv_msg becomes useless with
this patch. This patch (on top of Stephen's patch) removes it.

Regards
Patrick

--------------050300050105030606070004
Content-Type: text/x-patch;
 name="useless-var.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="useless-var.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/07/27 20:32:23+02:00 kaber@trash.net 
#   [NET]: Remove useless variable in rtnetlink_rcv_msg
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/core/rtnetlink.c
#   2004/07/27 20:32:10+02:00 kaber@trash.net +0 -4
#   [NET]: Remove useless variable in rtnetlink_rcv_msg
# 
diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
--- a/net/core/rtnetlink.c	2004-07-27 20:33:47 +02:00
+++ b/net/core/rtnetlink.c	2004-07-27 20:33:47 +02:00
@@ -335,7 +335,6 @@
 	struct rtnetlink_link *link_tab;
 	struct rtattr	*rta[RTATTR_MAX];
 
-	int exclusive = 0;
 	int sz_idx, kind;
 	int min_len;
 	int family;
@@ -401,9 +400,6 @@
 		skb_pull(skb, rlen);
 		return -1;
 	}
-
-	if (kind != 2) 
-		exclusive = 1;
 
 	memset(&rta, 0, sizeof(rta));
 

--------------050300050105030606070004--
