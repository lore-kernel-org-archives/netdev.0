From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Bluetooth BUG() in set_sk_owner().
Date: Mon, 15 Sep 2003 09:54:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063616050.21195.67.camel@hades.cambridge.redhat.com>
References: <1063184337.32473.529.camel@hades.cambridge.redhat.com>
	 <20030911182223.2e9b7118.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org, maxk@qualcomm.com,
   marcel@holtmann.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030911182223.2e9b7118.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-09-11 at 18:22 -0700, David S. Miller wrote:
> On Wed, 10 Sep 2003 09:58:57 +0100
> David Woodhouse <dwmw2@infradead.org> wrote:
> 
> > It loks like the recent addition of sk_set_owner() to 
> > bt_sock_alloc() was bogus... some of the callers of bt_sock_alloc()
> > already do that for  This patch reverts it, and makes the remaining
> > callers also set the owner for themselves...
> 
> Applied, thanks David.

Needs this too...

===== net/bluetooth/bnep/sock.c 1.11 vs edited =====
--- 1.11/net/bluetooth/bnep/sock.c	Thu Jun  5 01:57:08 2003
+++ edited/net/bluetooth/bnep/sock.c	Fri Sep 12 09:16:17 2003
@@ -186,7 +189,8 @@
 
 static struct net_proto_family bnep_sock_family_ops = {
 	.family = PF_BLUETOOTH,
-	.create = bnep_sock_create
+	.create = bnep_sock_create,
+	.owner = THIS_MODULE
 };
 
 int __init bnep_sock_init(void)


-- 
dwmw2
