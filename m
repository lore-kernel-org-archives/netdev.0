From: Eugene Teo <eugeneteo@kernel.sg>
Subject: [PATCH] sbni: missing capability checks in sbni_ioctl()
Date: Wed, 27 Aug 2008 11:19:54 +0800
Message-ID: <20080827031954.GA11597@kernel.sg>
Reply-To: Eugene Teo <eugeneteo@kernel.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, security@kernel.org, eteo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862AbYH0DUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 23:20:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This requires proper capability checks for the privileged operations.

Signed-off-by: Eugene Teo <eugeneteo@kernel.sg>
---
 drivers/net/wan/sbni.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index e59255a..6596cd0 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -1317,7 +1317,7 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 		break;
 
 	case  SIOCDEVRESINSTATS :
-		if( current->euid != 0 )	/* root only */
+		if (!capable(CAP_NET_ADMIN))
 			return  -EPERM;
 		memset( &nl->in_stats, 0, sizeof(struct sbni_in_stats) );
 		break;
@@ -1334,7 +1334,7 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 		break;
 
 	case  SIOCDEVSHWSTATE :
-		if( current->euid != 0 )	/* root only */
+		if (!capable(CAP_NET_ADMIN))
 			return  -EPERM;
 
 		spin_lock( &nl->lock );
@@ -1355,7 +1355,7 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 #ifdef CONFIG_SBNI_MULTILINE
 
 	case  SIOCDEVENSLAVE :
-		if( current->euid != 0 )	/* root only */
+		if (!capable(CAP_NET_ADMIN))
 			return  -EPERM;
 
 		if (copy_from_user( slave_name, ifr->ifr_data, sizeof slave_name ))
@@ -1370,7 +1370,7 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 		return  enslave( dev, slave_dev );
 
 	case  SIOCDEVEMANSIPATE :
-		if( current->euid != 0 )	/* root only */
+		if (!capable(CAP_NET_ADMIN))
 			return  -EPERM;
 
 		return  emancipate( dev );
