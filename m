From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [BRIDGE] convert __constant_htons(constant) to htons
Date: Sat, 02 Oct 2004 16:31:27 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415F020F.7010909@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020908070200080805000100"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020908070200080805000100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are two outstanding changesets in this tree.

Regards,

- Arnaldo

--------------020908070200080805000100
Content-Type: text/plain;
 name="bridge.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bridge.patch"

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.2031, 2004-10-02 16:27:19-03:00, acme@amd64.kerneljanitors.org
  [BRIDGE] convert __constant_htons(constant) to htons
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>
  


 ebt_arp.c      |    4 ++--
 ebt_arpreply.c |    6 +++---
 ebt_ip.c       |    2 +-
 ebt_log.c      |    2 +-
 ebt_vlan.c     |    2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)


diff -Nru a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_arp.c
--- a/net/bridge/netfilter/ebt_arp.c	2004-10-02 16:29:01 -03:00
+++ b/net/bridge/netfilter/ebt_arp.c	2004-10-02 16:29:01 -03:00
@@ -108,8 +108,8 @@
 
 	if (datalen != EBT_ALIGN(sizeof(struct ebt_arp_info)))
 		return -EINVAL;
-	if ((e->ethproto != __constant_htons(ETH_P_ARP) &&
-	   e->ethproto != __constant_htons(ETH_P_RARP)) ||
+	if ((e->ethproto != htons(ETH_P_ARP) &&
+	   e->ethproto != htons(ETH_P_RARP)) ||
 	   e->invflags & EBT_IPROTO)
 		return -EINVAL;
 	if (info->bitmask & ~EBT_ARP_MASK || info->invflags & ~EBT_ARP_MASK)
diff -Nru a/net/bridge/netfilter/ebt_arpreply.c b/net/bridge/netfilter/ebt_arpreply.c
--- a/net/bridge/netfilter/ebt_arpreply.c	2004-10-02 16:29:01 -03:00
+++ b/net/bridge/netfilter/ebt_arpreply.c	2004-10-02 16:29:01 -03:00
@@ -29,9 +29,9 @@
 	if (ap == NULL)
 		return EBT_DROP;
 
-	if (ap->ar_op != __constant_htons(ARPOP_REQUEST) ||
+	if (ap->ar_op != htons(ARPOP_REQUEST) ||
 	    ap->ar_hln != ETH_ALEN ||
-	    ap->ar_pro != __constant_htons(ETH_P_IP) ||
+	    ap->ar_pro != htons(ETH_P_IP) ||
 	    ap->ar_pln != 4)
 		return EBT_CONTINUE;
 
@@ -65,7 +65,7 @@
 		return -EINVAL;
 	if (BASE_CHAIN && info->target == EBT_RETURN)
 		return -EINVAL;
-	if (e->ethproto != __constant_htons(ETH_P_ARP) ||
+	if (e->ethproto != htons(ETH_P_ARP) ||
 	    e->invflags & EBT_IPROTO)
 		return -EINVAL;
 	CLEAR_BASE_CHAIN_BIT;
diff -Nru a/net/bridge/netfilter/ebt_ip.c b/net/bridge/netfilter/ebt_ip.c
--- a/net/bridge/netfilter/ebt_ip.c	2004-10-02 16:29:01 -03:00
+++ b/net/bridge/netfilter/ebt_ip.c	2004-10-02 16:29:01 -03:00
@@ -80,7 +80,7 @@
 
 	if (datalen != EBT_ALIGN(sizeof(struct ebt_ip_info)))
 		return -EINVAL;
-	if (e->ethproto != __constant_htons(ETH_P_IP) ||
+	if (e->ethproto != htons(ETH_P_IP) ||
 	   e->invflags & EBT_IPROTO)
 		return -EINVAL;
 	if (info->bitmask & ~EBT_IP_MASK || info->invflags & ~EBT_IP_MASK)
diff -Nru a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
--- a/net/bridge/netfilter/ebt_log.c	2004-10-02 16:29:01 -03:00
+++ b/net/bridge/netfilter/ebt_log.c	2004-10-02 16:29:01 -03:00
@@ -121,7 +121,7 @@
 
 		/* If it's for Ethernet and the lengths are OK,
 		 * then log the ARP payload */
-		if (ah->ar_hrd == __constant_htons(1) &&
+		if (ah->ar_hrd == htons(1) &&
 		    ah->ar_hln == ETH_ALEN &&
 		    ah->ar_pln == sizeof(uint32_t)) {
 			struct arppayload _arpp, *ap;
diff -Nru a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
--- a/net/bridge/netfilter/ebt_vlan.c	2004-10-02 16:29:01 -03:00
+++ b/net/bridge/netfilter/ebt_vlan.c	2004-10-02 16:29:01 -03:00
@@ -104,7 +104,7 @@
 	}
 
 	/* Is it 802.1Q frame checked? */
-	if (e->ethproto != __constant_htons(ETH_P_8021Q)) {
+	if (e->ethproto != htons(ETH_P_8021Q)) {
 		DEBUG_MSG
 		    ("passed entry proto %2.4X is not 802.1Q (8100)\n",
 		     (unsigned short) ntohs(e->ethproto));

===================================================================


This BitKeeper patch contains the following changesets:
1.2031
## Wrapped with gzip_uu ##


M'XL( 'T!7T$  ^U876_;-A1]MGX%AP)%BD$ROT1*1ATD38S6V(JZ3O,T# 8E
MT99F63(DQELP_OA15)IX21K;:OMFV:!HB9?WZ/+<HTN_ M>UK 8]$:^D\PI\
M*&LUZ,5E(6.5;807ERLOJLR-:5F:&WWYCZI$OQG<CY;]>CF+;N9S%WO,,6,F
M0L4IV,BJ'O201^ZOJ-NU'/2FH_?7OY]/'6<X!!>I*!;R2BHP'#JJK#8B3^HS
MH=*\+#SCH:A74EGO^GZHQA!B\_$1)]!G&C%(N8Y1@I"@2"80TX!1I\%V]O@!
M_C\+168FQ"CV0^V'(<7.)4 >A@0!2/L(]B$&B TP'Z#0A60 (;"SBE7"J+>4
M52'SOT21&>"U5U8+\*L/7.B\ S_V22Z<&/SQ;CJ^?#_Z$Y@G,H%58#8SO5J)
M0LU297HG7W^^,=Z!O63,S/<J6Q0R<4NS/-'M )Q7A4%6@@O10$Q+D$CP4>8E
M>/MLP$Z?SG I-ED"KCSP,<MS68&WB=C(U5DEDU2HQJRQ<7X##&/"G<G#&CON
M@8?C0 &=4Q E=9S>W*[.UJ)(RDIXD=2%5/VHRI*%[)ON/,N5K/HR4C-1K2NY
MSF^]N DO@0&F"!%$F:8,<:XI1)3BF!-"6)C$XN4EW==/2Z40<T@UHP%I8+=Q
M*6Y4[159L12>F>#;\V7K=B8,0\0P00@S32@,B$;()WZ$!4(\A',8=T7\U<,V
M5LH8H0=C-<_^#%C"@E 'B3!P&:."B@3&R7>$]RE:A'WF'XQVDXOB,5RN+0TT
M];D448AP,#=P&>T*]\''-E[LD^#PZ.;EXCDJ&"YH:I9?(.D+%,(PX%%7N/<N
MMM'ZC%-D97D/TC>"_5/STMD*FNWFY5SMI.5V2L+ 1,G,ZA,-,>?(JCMY+.V0
M[B?M!+CD*.UWTFX5[A-PJ[_OOD;G]UB6#F^ 2V(6RAG;MI?-P8E8NZ>BFI5K
M\,NP#<;)^73R:3*;CCY?CZZ^O %:&RMJK9JV!\QQ9[6NR@>ST9</L\EL/&DM
M6-!8V-;ZD>ZI5*DQ4$],C#]KLRM5VBSY:=+:+4.>)@>B04!L<O"NR8&!BX_)
MT29'^Y(Z(#FZY05""&!G;/AA3I:Q.RG[^K5-AA>&39MQN[F==:+V_A5.!V9G
MSQ";<AZVQ ZZ$AL!%QV)W1*[K17W)7;6D=<!:738MKMT>+R'#-M*YW"N'E"#
M?6.GN6_MU6P_H?8-\>&1JC^*JFTINR]5[8ITTF!LRXSVU&O+D]06&FF5&-+=
ML159Z7V1INW^X7">'K*WZ:"J6]L:4[!#%!*S5="8^;355?/R.;+UN]G:;A/W
M96N[)IWH"KFEJSWM$M? :--G4PO\^_"/7IS*>%G?K(9Q..<XP8'S'Y#WT^ V
#%   
 

--------------020908070200080805000100--
