From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] appletalk: remove MOD_{INC,DEC}_USE_COUNT
Date: Sun, 27 Apr 2003 13:10:56 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030427161056.GI15637@conectiva.com.br>
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

	Now there are five outstanding changesets in this tree.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1127, 2003-04-27 12:59:15-03:00, acme@conectiva.com.br
  o appletalk: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.


 ddp.c |   29 +++++++++--------------------
 1 files changed, 9 insertions(+), 20 deletions(-)


diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Sun Apr 27 13:04:11 2003
+++ b/net/appletalk/ddp.c	Sun Apr 27 13:04:11 2003
@@ -190,10 +190,9 @@
 	struct sock *sk = (struct sock *)data;
 
 	if (!atomic_read(&sk->wmem_alloc) &&
-	    !atomic_read(&sk->rmem_alloc) && test_bit(SOCK_DEAD, &sk->flags)) {
+	    !atomic_read(&sk->rmem_alloc) && test_bit(SOCK_DEAD, &sk->flags))
 		sock_put(sk);
-		MOD_DEC_USE_COUNT;
-	} else {
+	else {
 		sk->timer.expires = jiffies + SOCK_DESTROY_TIME;
 		add_timer(&sk->timer);
 	}
@@ -205,10 +204,9 @@
 	skb_queue_purge(&sk->receive_queue);
 
 	if (!atomic_read(&sk->wmem_alloc) &&
-	    !atomic_read(&sk->rmem_alloc) && test_bit(SOCK_DEAD, &sk->flags)) {
+	    !atomic_read(&sk->rmem_alloc) && test_bit(SOCK_DEAD, &sk->flags))
 		sock_put(sk);
-		MOD_DEC_USE_COUNT;
-	} else {
+	else {
 		init_timer(&sk->timer);
 		sk->timer.expires = jiffies + SOCK_DESTROY_TIME;
 		sk->timer.function = atalk_destroy_timer;
@@ -249,7 +247,6 @@
 			*iface = tmp->next;
 			kfree(tmp);
 			dev->atalk_ptr = NULL;
-			MOD_DEC_USE_COUNT;
 		} else
 			iface = &tmp->next;
 	}
@@ -259,13 +256,10 @@
 static struct atalk_iface *atif_add_device(struct net_device *dev,
 					   struct atalk_addr *sa)
 {
-	struct atalk_iface *iface;
-
-	MOD_INC_USE_COUNT;
+	struct atalk_iface *iface = kmalloc(sizeof(*iface), GFP_KERNEL);
 
-	iface = kmalloc(sizeof(*iface), GFP_KERNEL);
 	if (!iface)
-		goto out_mem;
+		goto out;
 
 	iface->dev = dev;
 	dev->atalk_ptr = iface;
@@ -278,9 +272,6 @@
 	write_unlock_bh(&atalk_interfaces_lock);
 out:
 	return iface;
-out_mem:
-	MOD_DEC_USE_COUNT;
-	goto out;
 }
 
 /* Perform phase 2 AARP probing on our tentative address */
@@ -982,17 +973,16 @@
 	struct atalk_sock *at;
 	int rc = -ESOCKTNOSUPPORT;
 
-	MOD_INC_USE_COUNT;
 	/*
 	 * We permit SOCK_DGRAM and RAW is an extension. It is trivial to do
 	 * and gives you the full ELAP frame. Should be handy for CAP 8) 
 	 */
 	if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
-		goto decmod;
+		goto out;
 	rc = -ENOMEM;
 	sk = sk_alloc(PF_APPLETALK, GFP_KERNEL, 1, NULL);
 	if (!sk)
-		goto decmod;
+		goto out;
 	at = at_sk(sk) = kmalloc(sizeof(*at), GFP_KERNEL);
 	if (!at)
 		goto outsk;
@@ -1005,8 +995,6 @@
 	return rc;
 outsk:
 	sk_free(sk);
-decmod:
-	MOD_DEC_USE_COUNT;
 	goto out;
 }
 
@@ -1785,6 +1773,7 @@
 static struct net_proto_family atalk_family_ops = {
 	.family		= PF_APPLETALK,
 	.create		= atalk_create,
+	.owner		= THIS_MODULE,
 };
 
 static struct proto_ops SOCKOPS_WRAPPED(atalk_dgram_ops) = {

===================================================================


This BitKeeper patch contains the following changesets:
1.1127
## Wrapped with gzip_uu ##


M'XL( 'O_JSX  ^U5;6^;.A3^C'_%N9I4)7<)L0%#R%6J;B';JO:V5;M\1JXQ
M"3> (^,TZAWWOU\;IFZMNDV;^G& =,#/\?,<GQ?Q"E:-4#.'\4J@5_!!-GKF
M<%D+KHL[YG)9N;?* -=2&F"RD968O#V;U$*//9<B@UPQS3=P)U0S<XCK/ZSH
M^YV8.=?+]ZOS-]<(S>>PV+!Z+6Z$AOD<::GN6)DU)TQO2EF[6K&ZJ83N--L'
MU];#V#,W)9&/:=B2$ =1RTE&" N(R+ 73,, V?!/GH;]F,7'@1<1ZOLD;/V 
M1@0E0%Q"O BP/\'!Q+P0;T;C&:%C[,\PAF=9X36!,49OX65/L$ <)+#=KC0,
MY78&2E3R3L#?ETGZZ?1B,4J6B__2U<TR75RN+CX:;_-<R /HC0 NE0!3DX-4
MVZ)>0U'GBC5:[;G>&^10E"4,\J)F97D_A$R:34Q#+E6WVVPT7#LEM>2RA)Q5
M15F(9@2%;N"??:.!0<6T%@ID#HW0VFK8G>-C>:C-<EZ(,C.J=M%0*;$N&N,N
M,NB#L!)I)Y!V[/<F>?#QP^E-:HZW.E^ZZ Q\2@**KKYT"1K_Y(409A@=_Z P
M)I3)0YHG6;9S^=<EBFG4FE:AI.51D$]%+/+<]_W,)\^WP[?X/K<;C;'7!F$8
MQ=T(/./\XV'XY8C1+5?EB2F#J?;WF'QSAR3&81"T- Y-&;K1B)\.!O:^/Q@Q
MC+W?D_'BD]&WSR6,U:%[3*=?/==)OS P"8E](.BT-PZ8ZP^F957P5 F6#8Z:
M[?A85:)*38(D'\+1$6C1Z/2VT(.;R\59FBS?)"/H_/*2K9OAT))2\"QI:$E%
MV0CXA!(/3ZU4;UY*RB/82GF$/)*BGOE,O- #WX!A8,'/"6<V86F1,R[@S][,
M85MUHH.F^%?(?-"O#T?P_MU5>K:\OEB>#_^R?&%/VQ^D,XZS-L4#N=?684J,
M8!)/J?6+8QO4:6\>^<4Q[1'Z%"'8I,?F+II&%G.[-G*<^==-,?KRW^4;P;?-
2OIJ'TSCV!8O0_U5H>BW2!P  
 
