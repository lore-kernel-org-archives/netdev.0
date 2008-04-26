From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH][CAN]: Fix copy_from_user() results interpretation.
Date: Sat, 26 Apr 2008 08:40:07 +0200
Message-ID: <20080426064007.GA20558@uranus.ravnborg.org>
References: <4811D1A6.909@openvz.org> <4811E915.80303@volkswagen.de> <4812C973.5000504@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Thuermann, Urs, Dr. (K-EFFI/I)" <urs.thuermann@volkswagen.de>,
	David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@openvz.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:49379 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844AbYDZGjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Apr 2008 02:39:35 -0400
Content-Disposition: inline
In-Reply-To: <4812C973.5000504@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 26, 2008 at 08:19:31AM +0200, Wolfgang Grandegger wrote:
> What about removing the assignment "err =" in that case.
Preferred.

See sample patch below (made on top of -linus
so it does likely not apply but made it only to
see the difference anyway).


	Sam

diffstat:
 net/can/raw.c          |   21 ++++++++++-----------
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/net/can/raw.c b/net/can/raw.c
index 201cbfc..69877b8 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -435,15 +435,13 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 			if (!filter)
 				return -ENOMEM;
 
-			err = copy_from_user(filter, optval, optlen);
-			if (err) {
+			if (copy_from_user(filter, optval, optlen)) {
 				kfree(filter);
-				return err;
+				return -EFAULT;
 			}
 		} else if (count == 1) {
-			err = copy_from_user(&sfilter, optval, optlen);
-			if (err)
-				return err;
+			if (copy_from_user(&sfilter, optval, optlen))
+				return -EFAULT;
 		}
 
 		lock_sock(sk);
@@ -493,9 +491,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 		if (optlen != sizeof(err_mask))
 			return -EINVAL;
 
-		err = copy_from_user(&err_mask, optval, optlen);
-		if (err)
-			return err;
+		if (copy_from_user(&err_mask, optval, optlen))
+			return -EFAULT;
 
 		err_mask &= CAN_ERR_MASK;
 
@@ -531,7 +528,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 		if (optlen != sizeof(ro->loopback))
 			return -EINVAL;
 
-		err = copy_from_user(&ro->loopback, optval, optlen);
+		if (copy_from_user(&ro->loopback, optval, optlen))
+			return -EFAULT;
 
 		break;
 
@@ -539,7 +537,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 		if (optlen != sizeof(ro->recv_own_msgs))
 			return -EINVAL;
 
-		err = copy_from_user(&ro->recv_own_msgs, optval, optlen);
+		if (copy_from_user(&ro->recv_own_msgs, optval, optlen))
+			return -EFAULT;
 
 		break;
 
