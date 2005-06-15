From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [-mm PATCH][3/4] net: signed vs unsigned cleanup in net/ipv4/raw.c
Date: Wed, 15 Jun 2005 23:31:44 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0506152308480.3842@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>, Ross Biro <ross.biro@gmail.com>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch changes the type of the local variable 'i' in 
raw_probe_proto_opt() from 'int' to 'unsigned int'. The only use of 'i' in 
this function is as a counter in a for() loop and subsequent index into 
the msg->msg_iov[] array.
Since 'i' is compared in a loop to the unsigned variable msg->msg_iovlen 
gcc -W generates this warning : 

net/ipv4/raw.c:340: warning: comparison between signed and unsigned

Changing 'i' to unsigned silences this warning and is safe since the array 
index can never be negative anyway, so unsigned int is the logical type to 
use for 'i' and also enables a larger msg_iov[] array (but I don't know if 
that will ever matter).


Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>
---

 net/ipv4/raw.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.12-rc6-mm1/net/ipv4/raw.c.with_patch-2	2005-06-15 23:04:40.000000000 +0200
+++ linux-2.6.12-rc6-mm1/net/ipv4/raw.c	2005-06-15 23:09:42.000000000 +0200
@@ -332,7 +332,7 @@ static void raw_probe_proto_opt(struct f
 	u8 __user *type = NULL;
 	u8 __user *code = NULL;
 	int probed = 0;
-	int i;
+	unsigned int i;
 
 	if (!msg->msg_iov)
 		return;
