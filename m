From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] ethertap update
Date: Tue, 2 Sep 2003 22:19:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902221925.B26380@electric-eye.fr.zoreil.com>
References: <20030902121114.4f489216.shemminger@osdl.org> <20030902121324.2d4c05f7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030902121324.2d4c05f7.davem@redhat.com>; from davem@redhat.com on Tue, Sep 02, 2003 at 12:13:24PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ethertap update]

Apply on top of Stephen's patch.

Balance alloc_netdev() with free_netdev().


 drivers/net/ethertap.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/net/ethertap.c~ethertap-free_netdev drivers/net/ethertap.c
--- linux-2.6.0-test4/drivers/net/ethertap.c~ethertap-free_netdev	Tue Sep  2 22:13:55 2003
+++ linux-2.6.0-test4-fr/drivers/net/ethertap.c	Tue Sep  2 22:14:49 2003
@@ -106,12 +106,12 @@ static int  __init ethertap_probe(int un
 
 	err = register_netdev(dev);
 	if (err)
-		goto out1;
+		goto out_free;
 
 	tap_map[unit]=dev;
 	return 0;
-out1:
-	kfree(dev);
+out_free:
+	free_netdev(dev);
 out:
 	return err;
 }

_
