From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] dont use strlen() but the result from a prior sprintf()
Date: Wed, 22 Jun 2005 14:56:55 +0200
Message-ID: <42B96017.1050803@cosmosbay.com>
References: <20050614154625.GB24371@esmail.cup.hp.com>	<1118771563.7059.30.camel@rh4>	<20050614211530.GB25516@esmail.cup.hp.com> <20050621.165634.07642938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030608070101010705060000"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050621.165634.07642938.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030608070101010705060000
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David

Small patch to save an unecessary call to strlen() : sprintf() gave us the length, just trust it.

Thank you

Eric Dumazet


diff -Nu linux-2.6.12-orig/net/socket.c linux-2.6.12/net/socket.c
--- linux-2.6.12-orig/net/socket.c      2005-06-22 14:47:56.000000000 +0200
+++ linux-2.6.12/net/socket.c   2005-06-22 14:49:22.000000000 +0200
@@ -382,9 +382,8 @@
                         goto out;
                 }

-               sprintf(name, "[%lu]", SOCK_INODE(sock)->i_ino);
+               this.len = sprintf(name, "[%lu]", SOCK_INODE(sock)->i_ino);
                 this.name = name;
-               this.len = strlen(name);
                 this.hash = SOCK_INODE(sock)->i_ino;

                 file->f_dentry = d_alloc(sock_mnt->mnt_sb->s_root, &this);


--------------030608070101010705060000
Content-Type: text/plain;
 name="patch.1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch.1"

--- linux-2.6.12-orig/net/socket.c	2005-06-22 14:47:56.000000000 +0200
+++ linux-2.6.12/net/socket.c	2005-06-22 14:49:22.000000000 +0200
@@ -382,9 +382,8 @@
 			goto out;
 		}
 
-		sprintf(name, "[%lu]", SOCK_INODE(sock)->i_ino);
+		this.len = sprintf(name, "[%lu]", SOCK_INODE(sock)->i_ino);
 		this.name = name;
-		this.len = strlen(name);
 		this.hash = SOCK_INODE(sock)->i_ino;
 
 		file->f_dentry = d_alloc(sock_mnt->mnt_sb->s_root, &this);

--------------030608070101010705060000--
