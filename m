From: James Morris <jmorris@intercode.com.au>
Subject: Re: 2.5.70-bk+ broken networking
Date: Thu, 5 Jun 2003 13:25:58 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306051325110.335-100000@excalibur.intercode.com.au>
References: <20030604184341.A10256@beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@digeo.com>, Stephen Hemminger <shemminger@osdl.org>,
   Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>,
   <netdev@oss.sgi.com>, <linux-kernel@vger.kernel.org>,
   Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick Mansfield <patmans@us.ibm.com>
In-Reply-To: <20030604184341.A10256@beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 Jun 2003, Patrick Mansfield wrote:

> [root@elm3b79 root]# ifup eth0
> sender address length == 0

This is a bug introduced by a coding style cleanup, fix below.


- James
-- 
James Morris
<jmorris@intercode.com.au>

--- bk.pending/net/core/iovec.c	2003-06-05 11:12:59.000000000 +1000
+++ bk.w1/net/core/iovec.c	2003-06-05 13:30:06.000000000 +1000
@@ -47,10 +47,10 @@ int verify_iovec(struct msghdr *m, struc
 						  address);
 			if (err < 0)
 				return err;
-			m->msg_name = address;
-		} else
-			m->msg_name = NULL;
-	}
+		}
+		m->msg_name = address;
+	} else
+		m->msg_name = NULL;
 
 	size = m->msg_iovlen * sizeof(struct iovec);
 	if (copy_from_user(iov, m->msg_iov, size))
