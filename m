From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] make sys_accept bump the net proto family module usage count
Date: Sun, 27 Apr 2003 10:56:40 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030427135640.GD14821@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please pull from:

bk://kernel.bkbits.net/acme/net-2.5

	I'll be shortly submitting the changes for LLC and IPX, etc.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1123, 2003-04-27 10:34:17-03:00, acme@conectiva.com.br
  o net/socket: make sys_accept bump the net proto family module usage count
    
  Thanks to Max Krasnyansky for spotting this.


 socket.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)


diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Sun Apr 27 10:46:55 2003
+++ b/net/socket.c	Sun Apr 27 10:46:55 2003
@@ -1288,24 +1288,28 @@
 	if (err)
 		goto out_release;
 
+	err = -EBUSY;
+	if (!net_family_get(sock->ops->family))
+		goto out_release;
+
 	err = sock->ops->accept(sock, newsock, sock->file->f_flags);
 	if (err < 0)
-		goto out_release;
+		goto out_family_put;
 
 	if (upeer_sockaddr) {
 		if(newsock->ops->getname(newsock, (struct sockaddr *)address, &len, 2)<0) {
 			err = -ECONNABORTED;
-			goto out_release;
+			goto out_family_put;
 		}
 		err = move_addr_to_user(address, len, upeer_sockaddr, upeer_addrlen);
 		if (err < 0)
-			goto out_release;
+			goto out_family_put;
 	}
 
 	/* File flags are not inherited via accept() unlike another OSes. */
 
 	if ((err = sock_map_fd(newsock)) < 0)
-		goto out_release;
+		goto out_family_put;
 
 	security_socket_post_accept(sock, newsock);
 
@@ -1313,7 +1317,8 @@
 	sockfd_put(sock);
 out:
 	return err;
-
+out_family_put:
+	net_family_put(sock->ops->family);
 out_release:
 	sock_release(newsock);
 	goto out_put;

===================================================================


This BitKeeper patch contains the following changesets:
1.1123
## Wrapped with gzip_uu ##


M'XL( $_?JSX  ]U4VVK;0!!]UG[%E+PD%,E[T=THI+F0%K?4.,U#H6#6ZY5M
M;&F%=N76H(_O6@ZQT[H)*7VJ)#2P<SAS9N:P)W"O99TZ7!02G<![I4WJ"%5*
M819K[@E5>)/:)D9*V41OK@K9NQST2FE<Z@7(9H;<B#FL9:U3AWCL\<1L*IDZ
MHYO;^X_O1@AE&5S->3F3=]) EB&CZC5?3?4%-_.5*CU3\U(7TG0UVT=H2S&F
M]@U(Q' 0MB3$?M0*,B6$^T1.,?7CT-^S;04^Q\6P3R-LN6C0,A8E!%T#\0BA
M###K8;]'(R X97Y*(A>S%&/8CN;BUY' 6P(N1I?P;_NX0@(4V.GVM!)+:5(H
M^%*"WN@Q%T)6!B9-48&9RRT(JEH9!3DO%JL-%&K:K"0TFL\D"-64QI(!V-\7
MJV*IK53XQ'_ H.:ZW%B5RPWDJ@9=*6,6Y<RR+K2'!L!8'% TW.\+N:]\$,(<
MH_,7AK-OTQ.'\TF"J W]* I:@?.(ACP/@BB?T$0<W\5O1-V2":.A)6+4I[2S
MWR'J90>^7AR:\K4L+LK&:*]<E$ON68ZCVA@."6.D)4F"=P8,_"?VHV$:O&0_
M#&[PG_JO6]EG<.OOW6?]-'RRO;_PXP="$PP^<F1=0P;NS>7]W=<^<A8YG+ZQ
MW.-=$^.9-*?;,NZYJK1[OCL].T..,]NVJAHSKN5*<BW[Z!NZMJP,2,>^C0>H
M![ZJ,?T.%C_ X@[V)YR]ESK<+CZ'BQ]P\7-E&0EW,!LI>II/D7/0MSTXTG=_
9?\&+N11+W119/@DC$5J[_P06.[E].P8     
 
