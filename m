From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH][LSM] remove net related includes from security.h
Date: Tue, 19 Oct 2004 15:21:51 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41755B3F.2040001@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040301020705080300040300"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040301020705080300040300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Chris,

	As discussed on irc.

Best Regards,

- Arnaldo

--------------040301020705080300040300
Content-Type: text/plain;
 name="lsm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lsm.patch"

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.2119, 2004-10-19 15:00:01-03:00, acme@conectiva.com.br
  [LSM] remove net related includes from security.h
  
  With this we're back to the times when changing skbuff.h
  only triggers rebuild of _net_ related stuff 8)
  
  This uncovered a bug in rmap.h, that was not including
  mm.h to get the definition of struct vm_area_struct,
  working by luck.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: Chris Wright <chrisw@osdl.org>


 include/linux/rmap.h     |    1 +
 include/linux/security.h |   20 +++++++-------------
 security/commoncap.c     |   17 +++++++++++++++++
 3 files changed, 25 insertions(+), 13 deletions(-)


diff -Nru a/include/linux/rmap.h b/include/linux/rmap.h
--- a/include/linux/rmap.h	2004-10-19 15:19:36 -03:00
+++ b/include/linux/rmap.h	2004-10-19 15:19:36 -03:00
@@ -7,6 +7,7 @@
 #include <linux/config.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include <linux/spinlock.h>
 
 /*
diff -Nru a/include/linux/security.h b/include/linux/security.h
--- a/include/linux/security.h	2004-10-19 15:19:36 -03:00
+++ b/include/linux/security.h	2004-10-19 15:19:36 -03:00
@@ -31,8 +31,6 @@
 #include <linux/shm.h>
 #include <linux/msg.h>
 #include <linux/sched.h>
-#include <linux/skbuff.h>
-#include <linux/netlink.h>
 
 /*
  * These functions are in security/capability.c and are used
@@ -53,18 +51,14 @@
 extern int cap_syslog (int type);
 extern int cap_vm_enough_memory (long pages);
 
-static inline int cap_netlink_send (struct sock *sk, struct sk_buff *skb)
-{
-	NETLINK_CB (skb).eff_cap = current->cap_effective;
-	return 0;
-}
+struct msghdr;
+struct sk_buff;
+struct sock;
+struct sockaddr;
+struct socket;
 
-static inline int cap_netlink_recv (struct sk_buff *skb)
-{
-	if (!cap_raised (NETLINK_CB (skb).eff_cap, CAP_NET_ADMIN))
-		return -EPERM;
-	return 0;
-}
+extern int cap_netlink_send(struct sock *sk, struct sk_buff *skb);
+extern int cap_netlink_recv(struct sk_buff *skb);
 
 /*
  * Values used in the task_security_ops calls
diff -Nru a/security/commoncap.c b/security/commoncap.c
--- a/security/commoncap.c	2004-10-19 15:19:36 -03:00
+++ b/security/commoncap.c	2004-10-19 15:19:36 -03:00
@@ -24,6 +24,23 @@
 #include <linux/xattr.h>
 #include <linux/hugetlb.h>
 
+int cap_netlink_send(struct sock *sk, struct sk_buff *skb)
+{
+	NETLINK_CB(skb).eff_cap = current->cap_effective;
+	return 0;
+}
+
+EXPORT_SYMBOL(cap_netlink_send);
+
+int cap_netlink_recv(struct sk_buff *skb)
+{
+	if (!cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN))
+		return -EPERM;
+	return 0;
+}
+
+EXPORT_SYMBOL(cap_netlink_recv);
+
 int cap_capable (struct task_struct *tsk, int cap)
 {
 	/* Derived from include/linux/sched.h:capable. */

===================================================================


This BitKeeper patch contains the following changesets:
1.2119
## Wrapped with gzip_uu ##


M'XL( +A:=4$  ^U8:V_;-A3];/Z*._3#DBV625&2+;L)\D07-"\D+;JA*PR*
MHBS!>@04%3>8]M]W:>?AID[0!-VGUJ]8%'GNX;WW',EY!>]KI8<=(0M%7L$?
M56V&'5F52IKL2CBR*IQ(XXGSJL(3/?79:-&SDWO1M%=/QU&3)%W7";IY)45.
M<.:9,#*%*Z7K88<Y_&[$7%^J8>?\X,W[HYUS0C8W82\5Y41=* .;F\14^DKD
M<;TM3)I7I8-QRKI09LZAO9O:NI2Z^/19GU,_:%E O7XK6<R8\)B*J>L- H]8
MAML/M_$EBL<H"^URUVT]YE%*]H$Y+F,A4*_': ^_,'](Z9"R+N7X!5:BPN\<
MNI3LPO?=P1Z1\/'HXO@3:%545PI*S)-6N3 JAJR4>1.K&A)=%5 KV>C,7#LI
MKL'7A\Q@NM.LAIGZ52N(A)PB.QQ28+("E\U258*TC+)R O745G&^NBKS:S Z
MFTRP?A@N:K(\ABJ!,88?W\6O#2Z P?HBWCL;JBDELM1X4D#43) BZ$)<.ND&
MQA4&9J*&LC(WU#$L+BP*)[7$)K@U2RY6259F)JM*&[(VNI$&KHJQT$J,%X<;
MN&Q6Z:GE'5U#WLBILV!QD4U*%7<K[,?H>@@[NL1B5+ G;%72"L'A6.45O%Y9
MQ:VO$?92C?OZ@,E(#;R6]FBV7=5Q[E1ZLD7> @_YP"-G]WU,NL]\$$(%)5LP
MT6JR/=652.>]<E/>7IZ5S>?>?7D7K=-GH>OZ^&C]( S=5O'(C;#&_;[+?2J#
MU6WZ).A""WT_Y&'+>3BPG,3TLKC;[L?;YO[T &=1XSD&HK@N\[GGM;3O,=;Z
M-.:)ZB<BBH4GDF_BM82WQ,GJA2.G!T588G6[GQZB%E4I$45:%$X1 Y>CK%M.
M@\!OO83[/E<R#*,@X<%CM!X#7*9%?3<(YU:V:A/6U;Y[$DG:3-)M%%IF1&VY
M?A/HP/48OI$R_AF$<Z=CWI+/>4,_'/+P:9]C/WWNA_2YA?I.H:MG\Q?ZUMG*
MCG^!_QUB\Y%7-V#P>H%F\[4UU]4J%5I=_1]&0';*6&>J=G9UU<R4WI:SS"GS
M;\#V:,@I\SW&:>MQ3@<+@;%G"ZS_4V$_I,+FUY$' EO5;"\1F!L ZY.L-( 0
M-OFHL>FX5F6\=I.7NL*J_E9/-VX3=7-?;\>B=?(/Z9P<O#LZ/'D[WMM=LT..
M2I(QHL$F($>M2M/=LN X/$^%&I&.5J;1)= 1^9?\30[^/#L]?S>^^.MX]_1H
M[2&1]1%.><A0*WFU]ABA+(&U7^QL+;):Q6N/$-R O9VS,9X<[^P?'YZLKY/.
M+;'NP=G!^?$SB%H^<Z)?7^_O96.]Z;O>S-W_+KJ\E&&?.K=M\_3]' W8@ W0
MBUCK^<Q?7/%Y^%Q#0C]B_*<A_7B&M/@1\.0E?ZDTSW>E?>Z!2_;] 'QR&%#\
MO$E)44_26(_(E\*_/T:K^N) Q,NS<4"9$=D/7 @0MX\QU&>C4-XO][_18Q"/
=&M3H_M\@,E5R6C?%9A &@P%-./D/)"G3TW$1    
 

--------------040301020705080300040300--
