From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] af_unix: remove MOD_{INC,DEC}_USE_COUNT
Date: Sun, 27 Apr 2003 23:15:15 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030428021515.GC17730@conectiva.com.br>
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

	Now there are just this outstanding changeset in this tree.

	Tested with af_unix as a module.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1129, 2003-04-27 23:06:26-03:00, acme@conectiva.com.br
  o af_unix: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.


 af_unix.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)


diff -Nru a/net/unix/af_unix.c b/net/unix/af_unix.c
--- a/net/unix/af_unix.c	Sun Apr 27 23:09:01 2003
+++ b/net/unix/af_unix.c	Sun Apr 27 23:09:01 2003
@@ -47,6 +47,9 @@
  *	     Alexey Kuznetsov   :	Full scale SMP. Lot of bugs are introduced 8)
  *	      Malcolm Beattie   :	Set peercred for socketpair
  *	     Michal Ostrowski   :       Module initialization cleanup.
+ *	     Arnaldo C. Melo	:	Remove MOD_{INC,DEC}_USE_COUNT,
+ *	     				the core infrastructure is doing that
+ *	     				for all net proto families now (2.5.69+)
  *
  *
  * Known differences from reference BSD that was tested:
@@ -360,7 +363,6 @@
 #ifdef UNIX_REFCNT_DEBUG
 	printk(KERN_DEBUG "UNIX %p is destroyed, %d are still alive.\n", sk, atomic_read(&unix_nr_socks));
 #endif
-	MOD_DEC_USE_COUNT;
 }
 
 static int unix_release_sock (unix_socket *sk, int embrion)
@@ -478,19 +480,16 @@
 
 static struct sock * unix_create1(struct socket *sock)
 {
-	struct sock *sk;
+	struct sock *sk = NULL;
 	struct unix_sock *u;
 
 	if (atomic_read(&unix_nr_socks) >= 2*files_stat.max_files)
-		return NULL;
+		goto out;
 
-	MOD_INC_USE_COUNT;
 	sk = sk_alloc(PF_UNIX, GFP_KERNEL, sizeof(struct unix_sock),
 		      unix_sk_cachep);
-	if (!sk) {
-		MOD_DEC_USE_COUNT;
-		return NULL;
-	}
+	if (!sk)
+		goto out;
 
 	atomic_inc(&unix_nr_socks);
 
@@ -509,7 +508,7 @@
 	init_MUTEX(&u->readsem); /* single task reading lock */
 	init_waitqueue_head(&u->peer_wait);
 	unix_insert_socket(&unix_sockets_unbound, sk);
-
+out:
 	return sk;
 }
 
@@ -1928,6 +1927,7 @@
 struct net_proto_family unix_family_ops = {
 	.family = PF_UNIX,
 	.create = unix_create,
+	.owner	= THIS_MODULE,
 };
 
 #ifdef CONFIG_SYSCTL

===================================================================


This BitKeeper patch contains the following changesets:
1.1129
## Wrapped with gzip_uu ##


M'XL( #V-K#X  ^U5VV[:0!!]]G[%5'G)!<RNK]@541) #0HA41*>T<:LP<7V
M5O8"C>K^>V=-1"[-18WRV,72HIV9,[-GYM@[,"Y%$1H\R@39@5-9JM"(9"XB
ME:RX&<G,O"W0<"4E&EISF8G6R5DK%ZIIF2Y!RR57T1Q6HBA#@YGV]D3=_1"A
M<=7_-AX>7Q'2Z4!WSO.9N!8*.AVB9+'BZ;0\XFJ>RMQ4!<_+3*@Z9[5UK2Q*
M+?RYS+>IZU7,HXY?16S*&'>8F%++:7L.T>4?/2_[*8I-'<MG'K,L6MDNLUW2
M V8R9@5 [19U6I8/EAU2+[2\)L4_%%Y$A0,&34I.X'-OT"412.#Q9)DG/T,H
M1"97 LXO>I-?@U&WT>MW?T_&U_U)]V(\ND%??$9R#6HN()*% .S(6A:+))]!
MDL<%+U6QC-02+>LD36$W3G*>IG=[,)48Q!7$LJBC,1"Q?A12R4BF$/,L21-1
M-B!1)7Q?E@HX9%PI48",H11*Z1PZLGDHUSD>QXE(IYA5'R)4(69)B>YB"ILB
M=(I)G6!2H]\A=7!S.KB>X/7&P[Y)SD!W)""7#S-"FO^X"*&<DL-WVH*EM#3#
MK7NFS>AQ?P+7KRAM,ZOBW/68'T=V'+O<%N[+L_ *G!ZU-D)ZS*WLMN.TZ_'_
MV_=]'7RTW%<$\6JYU&8. @65%:!(:F4X]+DNF/NV+@)H!O]U\<FZJ,?G IK%
MNGYPSB]?F*0/J&7@!& 3V#= K^,":4 *NB:<BU0:^.9^D^G&-M+ M67[&<5)
MB;1N:.'J281F&7G75]EPO"48<FS?+GY<3"\XV",]V[,!)])I,]P&F\VX)["4
MT0+VRP5T8#0>#K]J-W?CIC?#F&EDN52UQ:]Q @J.OKP-%C&2&':_E(N]IZXN
MLS3(9L.CD Q88%.-:-:M-3J/^]1X^ Q&<Q$MRF76N?7;D46=@/P!.3F(Y6$'
"    
 
