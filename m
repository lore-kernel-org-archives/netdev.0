From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [PATCH] net/socket.c : remove redundant NULL pointer check before
 kfree()
Date: Thu, 17 Mar 2005 20:34:05 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0503172028030.2512@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Orest Zborowski <obz@Kodak.COM>,
	Ross Biro <bir7@leland.Stanford.Edu>,
	"Fred N. van Kempen" <waltje@uWalt.NL.Mugnet.ORG>,
	"David S. Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: netdev@oss.sgi.com
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


kfree() handles NULL pointers just fine, checking first is pointless.


Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>

--- linux-2.6.11-mm4-orig/net/socket.c	2005-03-16 15:45:42.000000000 +0100
+++ linux-2.6.11-mm4/net/socket.c	2005-03-17 20:25:36.000000000 +0100
@@ -993,8 +993,7 @@ static int sock_fasync(int fd, struct fi
 	sock = SOCKET_I(filp->f_dentry->d_inode);
 
 	if ((sk=sock->sk) == NULL) {
-		if (fna)
-			kfree(fna);
+		kfree(fna);
 		return -EINVAL;
 	}
 




(Please CC me on replies to lists other than linux-kernel)


