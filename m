From: Joe Perches <joe@perches.com>
Subject: comment on [NET]: Delete support for old-style protocols, no
	longer necessary.
Date: Tue, 07 Oct 2003 11:37:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1065551829.2340.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@nuts.ninka.net, linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

How about

netdevice.h

struct sock;

struct packet_type {
        unsigned short          type;   /* This is really htons(ether_type).    */
        struct net_device               *dev;   /* NULL is wildcarded here              */
        int                     (*func) (struct sk_buff *, struct net_device *,
                                         struct packet_type *);
-       void                    *af_packet_priv;
+       struct sock             *sk;	/* appropriate comment: socket copy? */
        struct list_head        list;
 };

and s/af_packet_priv/sk/g in the rest of the files?
