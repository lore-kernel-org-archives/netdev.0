From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: remove verify_area() in net/wan/sbni
Date: Fri, 3 Oct 2003 21:35:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003213517.6700a095.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ncorbic@sangoma.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Please apply to 2.6.0-test6-current.

Thanks,
--
~Randy


From: Domen Puncer <domen@coderock.org>
Subject: [Kernel-janitors] [PATCH] updated: verify_area:
 	drivers/net/wan/sbni.c

Someone added error checking to copy_*_user, so this [earlier] patch
didn't apply.

Removed unnecessary verify_area.



 linux-260-test6-kj1-rddunlap/drivers/net/wan/sbni.c |   20 +++++---------------
 1 files changed, 5 insertions(+), 15 deletions(-)

diff -puN drivers/net/wan/sbni.c~net_wan_sbni_verify drivers/net/wan/sbni.c
--- linux-260-test6-kj1/drivers/net/wan/sbni.c~net_wan_sbni_verify	2003-09-29 17:39:09.000000000 -0700
+++ linux-260-test6-kj1-rddunlap/drivers/net/wan/sbni.c	2003-09-29 17:39:09.000000000 -0700
@@ -1300,12 +1300,9 @@ sbni_ioctl( struct net_device  *dev,  st
   
 	switch( cmd ) {
 	case  SIOCDEVGETINSTATS :
-		error = verify_area( VERIFY_WRITE, ifr->ifr_data,
-				     sizeof(struct sbni_in_stats) );
-		if( !error )
-			if (copy_to_user( ifr->ifr_data, &nl->in_stats,
-				      sizeof(struct sbni_in_stats) ))
-				return -EFAULT;
+		if (copy_to_user( ifr->ifr_data, &nl->in_stats,
+					sizeof(struct sbni_in_stats) ))
+			error = -EFAULT;
 		break;
 
 	case  SIOCDEVRESINSTATS :
@@ -1321,11 +1318,8 @@ sbni_ioctl( struct net_device  *dev,  st
 		flags.rxl	= nl->cur_rxl_index;
 		flags.fixed_rxl	= nl->delta_rxl == 0;
 
-		error = verify_area( VERIFY_WRITE, ifr->ifr_data,
-				     sizeof flags );
-		if( !error )
-			if (copy_to_user( ifr->ifr_data, &flags, sizeof flags ))
-				return -EFAULT;
+		if (copy_to_user( ifr->ifr_data, &flags, sizeof flags ))
+			error = -EFAULT;
 		break;
 
 	case  SIOCDEVSHWSTATE :
@@ -1353,10 +1347,6 @@ sbni_ioctl( struct net_device  *dev,  st
 		if( current->euid != 0 )	/* root only */
 			return  -EPERM;
 
-		if( (error = verify_area( VERIFY_READ, ifr->ifr_data,
-					  sizeof slave_name )) != 0 )
-			return  error;
-
 		if (copy_from_user( slave_name, ifr->ifr_data, sizeof slave_name ))
 			return -EFAULT;
 		slave_dev = dev_get_by_name( slave_name );

_
